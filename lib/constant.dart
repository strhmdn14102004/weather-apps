
class Parameter {
  static const bool API_PRINT_LOGGING_ENABLED = true;
}

class ApiUrl {
  static String MAIN_BASE = "https://posdemo.sisapp.com:8443/web-order/api/v1/";
  static String SECONDARY_BASE = "https://posdemo.sisapp.com:8443/web-order/api/v1/";
  static String _merchantCode = "PHDMJ1";
  
  static String get merchant => "merchants?code=$_merchantCode";
  static String menu = "menus";
  static String cart = "carts/add-to-cart";
  static String getcart = "carts";
  static String updatequantity = "carts/update-quantity?";

  static void setMerchantCode(String code) {
    _merchantCode = code;
  }
}
