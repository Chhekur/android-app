import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:local_market/components/app_bar.dart';
import 'package:local_market/components/cart_icon.dart';
import 'package:local_market/components/page.dart';
import 'package:local_market/components/product.dart';
import 'package:local_market/controller/category_controller.dart';
import 'package:local_market/controller/product_controller.dart';
import 'package:local_market/utils/utils.dart';
import 'package:local_market/views/product_view.dart';
import 'package:local_market/views/search.dart';

class Products extends StatefulWidget {
  String _tagId;
  String _subCategoryId;
  String _categoryId;

  Products(String tagId, String subCategoryId, String categoryId){
    this._tagId = tagId;
    this._subCategoryId = subCategoryId;
    this._categoryId = categoryId;
  }

  @override
  _ProductsState createState() => _ProductsState(this._tagId, this._subCategoryId, this._categoryId);
}

class _ProductsState extends State<Products> {

  final Utils _utils = new Utils();
  final ProductController _productController = new ProductController();
  final CategoryController _categoryController = new CategoryController();
  List<Map<String, String>> _tags = new List<Map<String, String>>();
  String _tagId;
  String _subCategoryId;
  String _categoryId;
  _ProductsState(this._tagId, this._subCategoryId, this._categoryId);
  bool _loading = true;
  ScrollController _scrollController = ScrollController();
  String lastProductName = null;
  bool moreProductAvailable = true;
  bool gettingMoreProducts = false;

  List<DocumentSnapshot> _products = null;

  @override
  void initState() {
    super.initState();
    _categoryController.getTag(this._categoryId, this._subCategoryId).then((tags){
      setState(() {
        this._tags = tags;
      });
    });
    if(this._tagId == null){
      _productController.getNBySubCategory(this._subCategoryId, 6).then((products){
        if(products.length < 6){
          this.moreProductAvailable = false;
        }
        setState(() {
          this._products = products;
          this.lastProductName = products[products.length - 1]['name'];
          this._loading = false;
        });
      });
    }else{
      _productController.getNByTag(this._subCategoryId, this._tagId, 6).then((products){
        if(products.length < 6){
          this.moreProductAvailable = false;
        }
        setState(() {
          this._products = products;
          this.lastProductName = products[products.length - 1]['name'];
          this._loading = false;
        });
      });
    }

    _scrollController.addListener((){
      double maxScroll = _scrollController.position.maxScrollExtent;
      double currentScroll = _scrollController.position.pixels;
      double delta = MediaQuery.of(context).size.height * 0.25;

      if(maxScroll - currentScroll <= delta){
        getMoreProducts();
      }
    });
  }

  void getMoreProducts(){
    if(moreProductAvailable){
      print('getting more products....');
      if(gettingMoreProducts == true) return;
      gettingMoreProducts = true;
      if(this._tagId == null){
        _productController.getNBySubCategoryNext(this._subCategoryId, 6, this.lastProductName).then((products){
          this._products.addAll(products);
          if(products.length < 6){
            this.moreProductAvailable = false;
          }
          this.lastProductName = products[products.length - 1]['name'];
          print(lastProductName);
          setState(() {
            
          });
          gettingMoreProducts = false;
        });
      }else{
        _productController.getNByTagNext(this._subCategoryId, this._tagId, 6, this.lastProductName).then((products){
          this._products.addAll(products);
          if(products.length < 6){
            this.moreProductAvailable = false;
          }
          this.lastProductName = products[products.length - 1]['name'];
          setState(() {
            
          });
          gettingMoreProducts = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Page(
      controller: _scrollController,
      appBar: RegularAppBar(
        backgroundColor: _utils.colors['appBar'],
        elevation: _utils.elevation,
        iconTheme: IconThemeData(color: _utils.colors['appBarIcons']),
        brightness: Brightness.light,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
              color: _utils.colors['appBarIcons']
            ),
            onPressed: (){
              Navigator.push(context, CupertinoPageRoute(builder: (context) => Search()));
            },
          ),
          CartIcon()
        ],
      ),
      children: <Widget>[
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: SliverToBoxAdapter(
            child: Container(
              height: 50,
              child: generateTagHorizontalScroll(this._tags),
            ),
          ),
        ),
        this._loading ? PageItem(child:SpinKitCircle(color: _utils.colors['loading'])) : PageGrid.builder(
          itemCount: this._products == null ? 0 : this._products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.698),
          itemBuilder: (context, i){
            return Product(this._products[i].data, false, false, 'products');
          }
        )
      ],
    );
  }

  Widget generateTagHorizontalScroll(List<Map<String, String>> tags){
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: tags.length,
      itemBuilder: (context, i){
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: (){
              Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context) => Products(tags[i]['id'], this._subCategoryId, this._categoryId)));
            },
            child: Chip(
              backgroundColor: _utils.colors['theme'],
              label: Text(
                tags[i]['name'],
                style: TextStyle(
                  color: _utils.colors['buttonText'],
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}