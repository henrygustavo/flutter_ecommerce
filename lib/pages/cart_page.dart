import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/app_state.dart';
import 'package:flutter_ecommerce/models/order.dart';
import 'package:flutter_ecommerce/models/user.dart';
import 'package:flutter_ecommerce/redux/actions.dart';
import 'package:flutter_ecommerce/widgets/product_item.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:stripe_payment/stripe_payment.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class CartPage extends StatefulWidget {
  final void Function() onInit;
  CartPage({this.onInit});

  @override
  CartPageState createState() => CartPageState();
}

class CartPageState extends State<CartPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isSubmitting = false;

  void initState() {
    super.initState();
    widget.onInit();
    StripeSource.setPublishableKey(
        'pk_test_24MfPM77rrcgpW2WhYngl5Ma00b5rG5SAf');
  }

  Widget _cartTab(state) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Column(children: [
      Expanded(
          child: SafeArea(
              top: false,
              bottom: false,
              child: GridView.builder(
                  itemCount: state.cartProducts.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          orientation == Orientation.portrait ? 2 : 3,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                      childAspectRatio:
                          orientation == Orientation.portrait ? 1.0 : 1.3),
                  itemBuilder: (context, i) =>
                      ProductItem(item: state.cartProducts[i]))))
    ]);
  }

  Widget _cardsTab(state) {
    _addCard(cardToken) async {
      final User user = state.user;
      // update user's data to include cardToken (PUT /users/:id)
      await http.put('https://flutter-ecommerce-api.herokuapp.com/users/${user.id}',
          body: {"card_token": cardToken},
          headers: {"Authorization": "Bearer ${user.jwt}"});
      // associate cardToken (added card) with Stripe customer (POST /card/add)
      http.Response response = await http.post('https://flutter-ecommerce-api.herokuapp.com/card/add',
          body: {"source": cardToken, "customer": user.customerId});
      final responseData = json.decode(response.body);
      return responseData;
    }

    return Column(children: [
      Padding(padding: EdgeInsets.only(top: 10.0)),
      RaisedButton(
          elevation: 8.0,
          child: Text('Add Card'),
          onPressed: () async {
            final String cardToken = await StripeSource.addSource();
            final card = await _addCard(cardToken);
            // Action to AddCard
            StoreProvider.of<AppState>(context).dispatch(AddCardAction(card));
            // Action to Update Card Token
            StoreProvider.of<AppState>(context)
                .dispatch(UpdateCardTokenAction(card['id']));
            // Show snackbar
            final snackbar = SnackBar(
                content:
                    Text('Card Added!', style: TextStyle(color: Colors.green)));
            _scaffoldKey.currentState.showSnackBar(snackbar);
          }),
      Expanded(
          child: ListView(
              children: state.cards
                  .map<Widget>((c) => (ListTile(
                      leading: CircleAvatar(
                          backgroundColor: Colors.deepOrange,
                          child: Icon(Icons.credit_card, color: Colors.white)),
                      title: Text(
                          "${c['card']['exp_month']}/${c['card']['exp_year']}, ${c['card']['last4']}"),
                      subtitle: Text(c['card']['brand']),
                      trailing: state.cardToken == c['id']
                          ? Chip(
                              avatar: CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.check_circle,
                                      color: Colors.white)),
                              label: Text("Primary Card"))
                          : FlatButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0))),
                              child: Text('Set as Primary',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.pink)),
                              onPressed: () {
                                StoreProvider.of<AppState>(context)
                                    .dispatch(UpdateCardTokenAction(c['id']));
                              }))))
                  .toList()))
    ]);
  }

  Widget _ordersTab(state) {
    return ListView(
        children: state.orders.length > 0
            ? state.orders
                .map<Widget>((order) => (ListTile(
                    title: Text('\$${order.amount}'),
                    subtitle: Text(DateFormat('MMM dd, yyyy - kk:mm')
                        .format(order.createdAt)),
                    leading: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.attach_money, color: Colors.white)))))
                .toList()
            : [
                Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.close, size: 60.0),
                          Text('No orders yet',
                              style: Theme.of(context).textTheme.title)
                        ]))
              ]);
  }

  String calculateTotalPrice(cartProducts) {
    double totalPrice = 0.0;
    cartProducts.forEach((cartProduct) {
      totalPrice += cartProduct.price;
    });
    return totalPrice.toStringAsFixed(2);
  }

  Future _showCheckoutDialog(state) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          if (state.cards.length == 0) {
            return AlertDialog(
                title: Row(children: [
                  Padding(
                      padding: EdgeInsets.only(right: 10.0),
                      child: Text('Add Card')),
                  Icon(Icons.credit_card, size: 60.0)
                ]),
                content: SingleChildScrollView(
                    child: ListBody(children: [
                  Text('Provide a credit card before checking out',
                      style: Theme.of(context).textTheme.body1)
                ])));
          }
          String cartSummary = '';
          state.cartProducts.forEach((cartProduct) {
            cartSummary += "· ${cartProduct.name}, \$${cartProduct.price}\n";
          });
          final primaryCard = state.cards
              .singleWhere((card) => card['id'] == state.cardToken)['card'];
          return AlertDialog(
              title: Text('Checkout'),
              content: SingleChildScrollView(
                  child: ListBody(children: [
                Text('CART ITEMS (${state.cartProducts.length})\n',
                    style: Theme.of(context).textTheme.body1),
                Text('$cartSummary', style: Theme.of(context).textTheme.body1),
                Text('CARD DETAILS\n',
                    style: Theme.of(context).textTheme.body1),
                Text('Brand: ${primaryCard['brand']}',
                    style: Theme.of(context).textTheme.body1),
                Text('Card Number: ${primaryCard['last4']}',
                    style: Theme.of(context).textTheme.body1),
                Text(
                    'Expires On: ${primaryCard['exp_month']}/${primaryCard['exp_year']}\n',
                    style: Theme.of(context).textTheme.body1),
                Text(
                    'ORDER TOTAL: \$${calculateTotalPrice(state.cartProducts)}',
                    style: Theme.of(context).textTheme.body1)
              ])),
              actions: [
                FlatButton(
                    onPressed: () => Navigator.pop(context, false),
                    color: Colors.red,
                    child:
                        Text('Close', style: TextStyle(color: Colors.white))),
                RaisedButton(
                    onPressed: () => Navigator.pop(context, true),
                    color: Colors.green,
                    child:
                        Text('Checkout', style: TextStyle(color: Colors.white)))
              ]);
        }).then((value) async {
      _checkoutCartProducts() async {
        // create new order in Strapi
        http.Response response =
            await http.post('https://flutter-ecommerce-api.herokuapp.com/orders', body: {
          "amount": calculateTotalPrice(state.cartProducts),
          "products": json.encode(state.cartProducts),
          "source": state.cardToken,
          "customer": state.user.customerId
        }, headers: {
          'Authorization': 'Bearer ${state.user.jwt}'
        });
        final responseData = json.decode(response.body);
        return responseData;
      }

      if (value == true) {
        // show loading spinner
        setState(() => _isSubmitting = true);
        // checkout cart products (create new order data in Strapi / charge card with Stripe)
        final newOrderData = await _checkoutCartProducts();
        // create order instance
        Order newOrder = Order.fromJson(newOrderData);
        // pass order instance to a new action (AddOrderAction)
        StoreProvider.of<AppState>(context).dispatch(AddOrderAction(newOrder));
        // clear out cart products
        StoreProvider.of<AppState>(context).dispatch(clearCartProductsAction);
        // hide loading spinner
        setState(() => _isSubmitting = false);
        // show success dialog
        _showSuccessDialog();
      }
    });
  }

  Future _showSuccessDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(title: Text('Success!'), children: [
            Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                    'Order successful!\n\nCheck your email for a receipt of your purchase!\n\nOrder summary will appear in your orders tab',
                    style: Theme.of(context).textTheme.body1))
          ]);
        });
  }

  Widget build(BuildContext context) {
    return StoreConnector<AppState, AppState>(
        converter: (store) => store.state,
        builder: (_, state) {
          return ModalProgressHUD(
              child: DefaultTabController(
                  length: 3,
                  initialIndex: 0,
                  child: Scaffold(
                      key: _scaffoldKey,
                      floatingActionButton: state.cartProducts.length > 0
                          ? FloatingActionButton(
                              child: Icon(Icons.local_atm, size: 30.0),
                              onPressed: () => _showCheckoutDialog(state))
                          : Text(''),
                      appBar: AppBar(
                          title: Text(
                              'Summary: ${state.cartProducts.length} Items · \$${calculateTotalPrice(state.cartProducts)}'),
                          bottom: TabBar(
                            labelColor: Colors.deepOrange[600],
                            unselectedLabelColor: Colors.deepOrange[900],
                            tabs: [
                              Tab(icon: Icon(Icons.shopping_cart)),
                              Tab(icon: Icon(Icons.credit_card)),
                              Tab(icon: Icon(Icons.receipt))
                            ],
                          )),
                      body: TabBarView(children: [
                        _cartTab(state),
                        _cardsTab(state),
                        _ordersTab(state)
                      ]))),
              inAsyncCall: _isSubmitting);
        });
  }
}
