import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import 'package:shop_mateo/db_helper.dart';
import 'cart_model.dart';
import 'cart_provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  DBHelper? dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.of(context).pop(),
            color: Colors.red,
          ),
          flexibleSpace: ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10 , sigmaY: 10),
              child: Container(color: Colors.transparent,),
            )),
          elevation: 0,
          backgroundColor: Colors.white.withAlpha(100),
          title: Text('My Products',
          style: TextStyle(color: Colors.black),),
          centerTitle: true,
          actions: [
            Center(
              child: badges.Badge(
                badgeContent: Consumer<CartProvider>(
                  builder: (context, value,  child){
                    return Text(value.getCounter().toString(),style: TextStyle(color: Colors.white),);
                  },
                ),
                child: Icon(Icons.shopping_cart_outlined,
                color: Colors.black,),
              ),
            ),
            SizedBox(width: 20,)
          ],
        ),
      body: Column(
        children: [
          FutureBuilder(
            future:cart.getData(),
              builder: (context , AsyncSnapshot<List<Cart>> snapshot ){
                if(snapshot.hasData){

                  if(snapshot.data!.isEmpty){
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image(
                          image: AssetImage('images/emptycart.jpg'),
                        ),
                        SizedBox(height: 20,),
                        Center(
                          child: Text('Explore Products to add to Cart' , style: Theme.of(context).textTheme.headlineSmall),
                        ),
                      ],
                    );
                  }else{
                    return Expanded(
                      child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index){
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Image(
                                          height: 100,
                                          width: 100,
                                          image: NetworkImage(snapshot.data![index].image.toString()),
                                        ),
                                        SizedBox(width: 10,),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(snapshot.data![index].productName.toString(),
                                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                                  ),
                                                  InkWell(
                                                      onTap: (){
                                                        dbHelper!.delete(snapshot.data![index].id!);
                                                        cart.removeCounter();
                                                        cart.removeTotalPrice(double.parse(snapshot.data![index].productPrice.toString()));
                                                      },
                                                      child: Icon(Icons.delete))
                                                ],
                                              ),

                                              SizedBox(height: 5,),
                                              Text(snapshot.data![index].unitTag.toString() +" "+r"$"+ snapshot.data![index].productPrice.toString(),
                                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                              ),
                                              SizedBox(height: 5,),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: InkWell(
                                                  onTap: () {

                                                  },
                                                  child: Container(
                                                    height: 35,
                                                    width: 100,
                                                    decoration: BoxDecoration(
                                                      color: Colors.green,
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child:  Padding(
                                                      padding: const EdgeInsets.all(4.0),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          InkWell(
                                                              onTap: (){
                                                                int quantity = snapshot.data![index].quantity!;
                                                                int price = snapshot.data![index].initialPrice!;
                                                                quantity--;
                                                                int? newPrice = price * quantity ;

                                                                if(quantity > 0){
                                                                  dbHelper!.updateQuantity(
                                                                      Cart(id: snapshot.data![index].id!,
                                                                          productId: snapshot.data![index].id!.toString(),
                                                                          productName: snapshot.data![index].productName!,
                                                                          initialPrice: snapshot.data![index].initialPrice,
                                                                          productPrice: newPrice,
                                                                          quantity: quantity,
                                                                          unitTag: snapshot.data![index].unitTag.toString(),
                                                                          image: snapshot.data![index].image.toString())
                                                                  ).then((value){
                                                                    newPrice = 0;
                                                                    quantity = 0;
                                                                    cart.removeTotalPrice(double.parse(snapshot.data![index].initialPrice!.toString()));
                                                                  }).onError((error, stackTrace){
                                                                    print(error.toString());
                                                                  });
                                                                }

                                                              },
                                                              child: Icon(Icons.remove, color: Colors.white,)),
                                                          Text(snapshot.data![index].quantity.toString(),
                                                              style: TextStyle(color: Colors.white)),
                                                          InkWell(
                                                              onTap: (){
                                                                int quantity = snapshot.data![index].quantity!;
                                                                int price = snapshot.data![index].initialPrice!;
                                                                quantity++;
                                                                int? newPrice = price * quantity ;
                                                                dbHelper!.updateQuantity(
                                                                    Cart(id: snapshot.data![index].id!,
                                                                        productId: snapshot.data![index].id!.toString(),
                                                                        productName: snapshot.data![index].productName!,
                                                                        initialPrice: snapshot.data![index].initialPrice,
                                                                        productPrice: newPrice,
                                                                        quantity: quantity,
                                                                        unitTag: snapshot.data![index].unitTag.toString(),
                                                                        image: snapshot.data![index].image.toString())
                                                                ).then((value){
                                                                  newPrice = 0;
                                                                  quantity = 0;
                                                                  cart.addTotalPrice(double.parse(snapshot.data![index].initialPrice!.toString()));
                                                                }).onError((error, stackTrace){
                                                                  print(error.toString());
                                                                });
                                                              },
                                                              child: Icon(Icons.add, color: Colors.white,)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            );
                          }),
                    );
                  }

                }
                return Text('');
              }),
          Consumer<CartProvider>(builder: (context, value, child){
            return Visibility(
              visible: value.getTotalPrice().toStringAsFixed(2) =='0.00' ? false : true,
              child: Column(
                children: [
                  ReusableWidget(title: '  Total Amount :                                                ', value: r"$"+ value.getTotalPrice().toStringAsFixed(2),)
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}



class ReusableWidget extends StatelessWidget {
  final String title,  value;
  const ReusableWidget({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium,),
          Text(value.toString(), style: Theme.of(context).textTheme.titleMedium,)
        ],
      ),
    );
  }
}

