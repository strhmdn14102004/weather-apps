import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_sasat/api/common/custom_log_interceptor.dart';
import 'package:weather_sasat/api/interceptor/authorize_interceptor.dart';
import 'package:weather_sasat/constant.dart';

class ApiManager {
  static bool PRIMARY = true;

  static Future<Dio> getDio({
    bool plain = false,
  }) async {
    String baseUrl;

    if (PRIMARY) {
      baseUrl = ApiUrl.MAIN_BASE;
    } else {
      baseUrl = ApiUrl.SECONDARY_BASE;
    }

    Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: Headers.jsonContentType,
        responseDecoder: (responseBytes, options, responseBody) {
          if (plain) {
            options.responseType = ResponseType.plain;
          }

          return utf8.decode(responseBytes, allowMalformed: true);
        },
      ),
    );

    dio.interceptors.add(AuthorizationInterceptor());
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    dio.interceptors.add(CustomLogInterceptor());

    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      HttpClient httpClient = HttpClient();

      httpClient.badCertificateCallback = (cert, host, port) => true;

      return httpClient;
    };

    return dio;
  }

  Future<Uint8List> download({
    required String url,
  }) async {
    Response response = await Dio()
        .get(url, options: Options(responseType: ResponseType.bytes));

    return response.data;
  }

  final dio = Dio();

  Future<Map<String, dynamic>> getMerchantData() async {
    try {
      final Dio dio = await getDio();
      final Response response = await dio.get(ApiUrl.merchant);

      if (response.statusCode == 200) {
        final merchantData = response.data;

        // Store the tableId in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final tableId = merchantData['tableId'].toString();
        await prefs.setString('table_id', tableId);

        return merchantData;
      } else {
        throw Exception('Failed to load merchant data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load merchant data');
    }
  }

  Future<Map<String, dynamic>> getMenuData() async {
    try {
      final Dio dio = await getDio();

      final merchantData = await getMerchantData();
      final merchantId = merchantData['id'];

      final Response response = await dio.get(
        ApiUrl.menu,
        options: Options(
          headers: {
            'X-Weborder-Merchant-Id': '$merchantId',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load menu data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load menu data');
    }
  }

  Future<void> addToCart(Map<String, dynamic> requestData) async {
    try {
      final Dio dio = await getDio();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String tableId = prefs.getString('table_id') ?? '4';
      final deviceId = prefs.getString('device_id') ?? '001';

      final Response response = await dio.post(
        ApiUrl.cart,
        data: requestData,
        options: Options(
          headers: {
            'X-Weborder-Table-Id': tableId,
            'X-Weborder-Device-Id': deviceId,
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Item Berhasil ditambahkan ke keranjang');
      } else {
        throw Exception('Gagal menambahkan item ke keranjang');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Gagal menambahkan item ke keranjang');
    }
  }

  Future<Map<String, dynamic>> getCart() async {
    try {
      final Dio dio = await getDio();

      final prefs = await SharedPreferences.getInstance();
      final tableId = prefs.getString('table_id') ?? '4';
      final deviceId = prefs.getString('device_id') ?? '001';

      final Response response = await dio.get(
        ApiUrl.getcart,
        options: Options(
          headers: {
            'X-Weborder-Table-Id': tableId,
            'X-Weborder-Device-Id': deviceId,
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to load cart data');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load cart data');
    }
  }

  Future<void> updateCartItemQuantity(String itemId, int quantity) async {
    try {
      final Dio dio = await getDio();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String tableId = prefs.getString('table_id') ?? '4';
      final String deviceId = prefs.getString('device_id') ?? '001';

      final response = await dio.put(
        '${ApiUrl.updatequantity}id=$itemId&quantity=$quantity',
        options: Options(
          headers: {
            'X-Weborder-Table-Id': tableId,
            'X-Weborder-Device-Id': deviceId,
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Item quantity updated successfully');
      } else {
        throw Exception('Failed to update item quantity');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to update item quantity');
    }
  }
}
