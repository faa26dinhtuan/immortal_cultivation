import '../features/world/world_region.dart';

abstract final class GameStrings {
  static const appTitle = 'Immortal Cultivation';
  static const regionLabel = 'Bản đồ vùng';
  static const regionName = 'Thanh Khê';
  static const mapDescription = 'Thung lũng nhìn từ trên cao, với sông, rừng và núi';
  static const alreadyHere = 'Đang ở đây';

  static String placeName(WorldPlace place) => switch (place) {
    WorldPlace.cave => 'Động Phủ',
    WorldPlace.landing => 'Bến Hợp Lưu',
    WorldPlace.pass => 'Đèo Vân Nham',
  };

  static String placeDescription(WorldPlace place) => switch (place) {
    WorldPlace.cave => 'Động đá nằm gần lối xuống thung lũng.',
    WorldPlace.landing => 'Bãi bồi nơi các nhánh suối gặp nhau.',
    WorldPlace.pass => 'Lối qua núi men theo khe đá.',
  };

  static String clock(int day, int hour) =>
      'Ngày $day · ${hour.toString().padLeft(2, '0')}:00';
  static String currentPlace(WorldPlace place) => 'Đang ở ${placeName(place)}';
  static String travel(int hours) => 'Di chuyển · $hours giờ';
  static String arrival(WorldPlace place, int hours) =>
      'Đã đến ${placeName(place)} sau $hours giờ.';
}
