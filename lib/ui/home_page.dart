import 'dart:io';

import 'package:agenda_de_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:agenda_de_contatos/helpers/contact_helper.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {
  orderAZ,orderZA
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Contact> contacts = [];
  ContactHelper helper = ContactHelper();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  void _getAllContacts() {
    helper.getAllContacts().then((value) {
      setState(() {
        contacts = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text("Ordenar de A-Z"), value: OrderOptions.orderAZ),
              const PopupMenuItem(child: Text("Ordenar de Z-A"), value: OrderOptions.orderZA)
            ],
            onSelected: (option) {
              _orderList(option);
            },
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        _showOptions(context, index);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(fit: BoxFit.cover, image: contacts[index].img != null ?
                    FileImage(File(contacts[index].img)) : AssetImage("images/person.png"))),
              ),
              Padding(padding: EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(contacts[index].name ?? "", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                  Text(contacts[index].email ?? "", style: TextStyle(fontSize: 18)),
                  Text(contacts[index].phone ?? "", style: TextStyle(fontSize: 18))
                ],
              ),)
            ],
          ),
        ),
      ),
    );
  }

  void _orderList(OrderOptions result) {
    if (result == OrderOptions.orderAZ) {
      contacts.sort((a,b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else {
      contacts.sort((b,a) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    }
    setState(() {});
  }

  void _showOptions(BuildContext context, int index) {
    const fontStyle = TextStyle(fontSize: 20, color: Colors.red);

    showModalBottomSheet(context: context, builder: (context) {
      return BottomSheet(builder: (context) {
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FlatButton(child: Text("Ligar", style: fontStyle), onPressed: () {
                Navigator.pop(context);
                launch("tel:${contacts[index].phone}");
              }),
              FlatButton(child: Text("Editar", style: fontStyle,), onPressed: () {
                Navigator.pop(context);
                _showContactPage(contact: contacts[index]);
              }),
              FlatButton(child: Text("Remover", style: fontStyle), onPressed: () {
                helper.deleteContact(contacts[index].id);
                setState(() {
                  contacts.removeAt(index);
                  Navigator.pop(context);
                });
              }),
            ],
          ),
        );
      }, onClosing: () {});
    });
  }


  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(context, MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }
}
