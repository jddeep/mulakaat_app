import 'package:flutter/material.dart';

import 'package:flutter_i18n/flutter_i18n.dart';

import '../snack.dart';

class InternationalizationPage extends StatefulWidget {
  @override

  I18n createState() => I18n();
}

class I18n extends State<InternationalizationPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        leading: IconButton(icon: Icon(Icons.arrow_back, color: Colors.white,), onPressed: ()=>Navigator.pop(context)),
        title: Text(FlutterI18n.translate(context, 'app.settings'), style: TextStyle(color: Colors.white,fontFamily: 'Montserrat', fontWeight: FontWeight.w700),),
      ),
      body: Builder(builder: (BuildContext context) {
        BuildContext scaffoldContext = context;
        return ListView(
          children: <Widget>[
            ListTile(  
              title: Text('English', style: TextStyle(fontFamily: 'Montserrat'),),
              onTap: () {
                Locale newLocale = Locale('en');
                setState(() {
                  FlutterI18n.refresh(context, newLocale);
                  snack(scaffoldContext, 'Language Changed to English');
                });
              }, 
            ),
            ListTile( 
              title: Text('Español', style: TextStyle(fontFamily: 'Montserrat'),),
              onTap: () {
                Locale newLocale = Locale('en');
                setState(() {
                  FlutterI18n.refresh(context, newLocale);
                  snack(scaffoldContext, 'Language changed to Spanish');
                });
              }, 
            ),
            ListTile(  
              title: Text('Hindi',  style: TextStyle(fontFamily: 'Montserrat'),),
              onTap: () {
                Locale newLocale = Locale('es');
                setState(() {
                  FlutterI18n.refresh(context, newLocale);
                  snack(scaffoldContext, 'भाषा बदलकर हिंदी हो गई');
                });
              }, 
            ),
          ],
        );
      }),
    );
  }

}
