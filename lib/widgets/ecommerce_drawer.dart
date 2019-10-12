import 'package:flutter/material.dart';
import 'package:flutter_ecommerce/models/user.dart';

class EcommerceDrawer extends StatelessWidget {

  final User user;

  EcommerceDrawer({this.user});

  @override
  Widget build(BuildContext context) {
    
    return Drawer(
      child: ListView(

        children: _buildDrawerList(context)

      ),
    );

  }

  // cracion de las listas para el drawer

  List<Widget> _buildDrawerList(BuildContext context) {
    List<Widget> children = [];
    children..addAll(_buildUserAccounts(context))
      ..addAll([new Divider()])
      ..addAll(_buildActions(context))
      ..addAll([new Divider()])
      ..addAll(_buildSettingAndHelp(context));
    return children;
  }
  
  List<Widget> _buildUserAccounts(BuildContext context) {

    List<Widget> _ret = [];

    if(user != null) {
      _ret..add(
      
        new UserAccountsDrawerHeader(
          accountName: Text(user.username),
          accountEmail: Text(user.email),
          currentAccountPicture: GestureDetector(
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
          ),
        )
      );
    } else {

      _ret..add(
        InkWell(
          onTap: () =>
              Navigator.pushNamed(context, '/register'),
          child: Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: ListTile(
              title: Text('Register'),
              leading: Icon(Icons.person,
                color: Colors.yellow,
              ),
            ),
          ),
        )
      );

      _ret..add(
        InkWell(
          onTap: () =>
              Navigator.pushNamed(context, '/login'),
          child: ListTile(
            title: Text('Login'),
            leading: Icon(Icons.person),
          ),
        )
      );

    }
    

    return _ret;
  }
  
  List<Widget> _buildActions(BuildContext context) {
    return [
      InkWell(
          onTap: () {},
          child: ListTile(
            title: Text('Home page'),
            leading: Icon(Icons.home),
          ),
        ),
        InkWell(
          onTap: () {},
          child: ListTile(
            title: Text('My Account'),
            leading: Icon(
              Icons.person,
            ),
          ),
        ),
        InkWell(
          onTap: () => Navigator.pushNamed(context, '/cart'),
          child: ListTile(
            title: Text('My orders'),
            leading: Icon(
              Icons.shopping_basket,
            ),
          ),
        ),
    ];
  }
  
  List<Widget> _buildSettingAndHelp(BuildContext context) {
    return [
      
        InkWell(
          onTap: () {},
          child: ListTile(
            title: Text('About'),
            leading: Icon(
              Icons.help,
              color: Colors.green,
            ),
          ),
        ),
    ];
  }
}
