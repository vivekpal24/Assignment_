class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  
  // Endpoints
  static const String search = '/search.php'; // ?s=Term
  static const String lookup = '/lookup.php'; // ?i=Id
  static const String random = '/random.php';
  static const String categories = '/categories.php';
  static const String list = '/list.php'; // ?c=list, ?a=list, ?i=list
  static const String filter = '/filter.php'; // ?c=Category, ?a=Area, ?i=Ingredient
  
  // Params
  static const String paramSearch = 's';
  static const String paramId = 'i';
  static const String paramCategory = 'c';
  static const String paramArea = 'a';
}
