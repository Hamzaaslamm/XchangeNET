import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:xchange_net/core/app_data.dart';
import 'package:xchange_net/core/extensions.dart';
import 'package:xchange_net/src/model/ad.dart';
import 'package:xchange_net/src/model/numerical.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:xchange_net/src/model/ad_category.dart';
import 'package:xchange_net/src/model/product_size_type.dart';
class AdController extends GetxController {
  RxList<Ad> allAds = AppData.ads.obs;
  RxList<Ad> filteredProducts = AppData.ads.obs;
  RxList<Ad> adsProducts = <Ad>[].obs;
  RxList<AdCategory> categories = AppData.categories.obs;
  int length = AdType.values.length;
  RxInt totalPrice = 0.obs;
  RxInt currentBottomNavItemIndex = 0.obs;
  RxInt productImageDefaultIndex = 0.obs;

  void filterItemsByCategory(int index) {
    for (AdCategory element in categories) {
      element.isSelected = false;
    }
    categories[index].isSelected = true;

    if (categories[index].type == AdType.all) {
      filteredProducts.assignAll(allAds);
    } else {
      filteredProducts.assignAll(allAds.where((item) {
        return item.type == categories[index].type;
      }).toList());
    }
  }

  void isLiked(int index) {
    filteredProducts[index].isLiked = !filteredProducts[index].isLiked;
    filteredProducts.refresh();
  }

  void addToCart(Ad ad) {
    ad.quantity++;
    adsProducts.add(ad);
    adsProducts.assignAll(adsProducts.distinctBy((item) => item));
    calculateTotalPrice();
  }

  void increaseItem(int index) {
    Ad product = adsProducts[index];
    product.quantity++;
    calculateTotalPrice();
    update();
  }

  bool get isZeroQuantity {
    return adsProducts.any(
          (element) {
        return element.price.compareTo(0) == 0 ? true : false;
      },
    );
  }

  bool isPriceOff(Ad product) {
    if (product.off != null) {
      return true;
    } else {
      return false;
    }
  }

  bool get isEmptyAds {
    if (adsProducts.isEmpty || isZeroQuantity) {
      return true;
    } else {
      return false;
    }
  }

  bool isNominal(Ad product) {
    if (product.sizes?.numerical != null) {
      return true;
    } else {
      return false;
    }
  }

  void decreaseItem(int index) {
    Ad product = adsProducts[index];
    if (product.quantity > 0) {
      product.quantity--;
    }
    calculateTotalPrice();
    update();
  }

  void calculateTotalPrice() {
    totalPrice.value = 0;
    for (var element in adsProducts) {
      if (isPriceOff(element)) {
        totalPrice.value += element.quantity * element.off!;
      } else {
        totalPrice.value += element.quantity * element.price;
      }
    }
  }

  void switchBetweenBottomNavigationItems(int index) {
    switch (index) {
      case 0:
        filteredProducts.assignAll(allAds);
        break;
      case 1:
        getLikedItems();
        break;
      case 2:
        adsProducts.assignAll(allAds.where((item) => item.quantity > 0));
    }
    currentBottomNavItemIndex.value = index;
  }

  void switchBetweenProductImages(int index) {
    productImageDefaultIndex.value = index;
  }

  void getLikedItems() {
    filteredProducts.assignAll(allAds.where((item) => item.isLiked));
  }

  List<Numerical> sizeType(Ad product) {
    ProductSizeType? productSize = product.sizes;
    List<Numerical> numericalList = [];

    if (productSize?.numerical != null) {
      for (var element in productSize!.numerical!) {
        numericalList.add(Numerical(element.numerical, element.isSelected));
      }
    }

    if (productSize?.categorical != null) {
      for (var element in productSize!.categorical!) {
        numericalList
            .add(Numerical(element.categorical.name, element.isSelected));
      }
    }

    return numericalList;
  }

  void switchBetweenProductSizes(Ad product, int index) {
    sizeType(product).forEach((element) {
      element.isSelected = false;
    });

    if (product.sizes?.categorical != null) {
      for (var element in product.sizes!.categorical!) {
        element.isSelected = false;
      }

      product.sizes?.categorical![index].isSelected = true;
    }

    if (product.sizes?.numerical != null) {
      for (var element in product.sizes!.numerical!) {
        element.isSelected = false;
      }

      product.sizes?.numerical![index].isSelected = true;
    }

    update();
  }

  String getCurrentSize(Ad product) {
    String currentSize = "";
    if (product.sizes?.categorical != null) {
      for (var element in product.sizes!.categorical!) {
        if (element.isSelected) {
          currentSize = "Size: ${element.categorical.name}";
        }
      }
    }

    if (product.sizes?.numerical != null) {
      for (var element in product.sizes!.numerical!) {
        if (element.isSelected) {
          currentSize = "Size: ${element.numerical}";
        }
      }
    }
    return currentSize;
  }
}
