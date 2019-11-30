import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/app_state.dart';
import 'package:flutter_ecommerce/models/message_notification.dart';
import 'package:flutter_ecommerce/redux/actions.dart';
import 'package:flutter_ecommerce/widgets/product_item.dart';
import 'package:flutter_redux/flutter_redux.dart';
import '../widgets/ecommerce_drawer.dart';
import 'package:badges/badges.dart';

final gradientBackground = BoxDecoration(
    gradient: LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        stops: [
      0.1,
      0.3,
      0.5,
      0.7,
      0.9
    ],
        colors: [
      //Colors.deepOrange[300],
      Colors.cyan[300],
      Colors.cyan[400],
      Colors.cyan[500],
      Colors.cyan[600],
      Colors.cyan[700]
    ]));

class ProductsPage extends StatefulWidget {
  final void Function() onInit;
  ProductsPage({this.onInit});

  @override
  ProductsPageState createState() => ProductsPageState();
}

class ProductsPageState extends State<ProductsPage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void initState() {
    super.initState();
    widget.onInit();
    setFirebaseConfig();
  }

  final _drawer = StoreConnector<AppState, AppState>(
      converter: (store) => store.state,
      builder: (context, state) {
        return EcommerceDrawer(user: state.user);
      });

  final _appBar = PreferredSize(
      preferredSize: Size.fromHeight(60.0),
      child: StoreConnector<AppState, AppState>(
          converter: (store) => store.state,
          builder: (context, state) {
            return AppBar(
                centerTitle: true,
                title: Text('Ropas Fashion'),
                actions: [
                  state.user != null
                      ? BadgeIconButton(
                          itemCount: state.cartProducts.length,
                          badgeColor: Colors.lime,
                          badgeTextColor: Colors.black,
                          icon: Icon(Icons.store),
                          onPressed: () =>
                              Navigator.pushNamed(context, '/cart'))
                      : Text(''),
                  Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: StoreConnector<AppState, VoidCallback>(
                          converter: (store) {
                        return () => store.dispatch(logoutUserAction);
                      }, builder: (_, callback) {
                        return state.user != null
                            ? IconButton(
                                icon: Icon(Icons.exit_to_app),
                                onPressed: callback)
                            : Text('');
                      })),
                ]);
          }));

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
        appBar: _appBar,
        drawer: _drawer,
        body: Container(
            decoration: gradientBackground,
            child: StoreConnector<AppState, AppState>(
                converter: (store) => store.state,
                builder: (_, state) {
                  return Column(children: [
                    Expanded(
                        child: SafeArea(
                            top: false,
                            bottom: false,
                            child: GridView.builder(
                                itemCount: state.products.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount:
                                            orientation == Orientation.portrait
                                                ? 2
                                                : 3,
                                        crossAxisSpacing: 4.0,
                                        mainAxisSpacing: 4.0,
                                        childAspectRatio:
                                            orientation == Orientation.portrait
                                                ? 1.0
                                                : 1.3),
                                itemBuilder: (context, i) =>
                                    ProductItem(item: state.products[i]))))
                  ]);
                })));
  }

  void setFirebaseConfig() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> notification) async {
        print('onMessage');
          var token = await _firebaseMessaging.getToken();
     
          print("Instance ID: $token");
         redirectToMessageWiget(notification);
      },
      onLaunch: (Map<String, dynamic> notification) async {
        print('onLaunch');

        redirectToMessageWiget(notification);
      },
      onResume: (Map<String, dynamic> notification) async {
        print('onResume');
        redirectToMessageWiget(notification);
      },
    );
    _firebaseMessaging.requestNotificationPermissions();
  }

  void redirectToMessageWiget(Map<String, dynamic> notification) {
    
    setState(() {
      var messageNotification = MessageNotification(
        title: notification["data"]["title"],
        body: notification["data"]["body"],
        color: Colors.blue,
      );

       Navigator.pushNamed(context, '/notification',arguments: messageNotification);
    });
  }
}
