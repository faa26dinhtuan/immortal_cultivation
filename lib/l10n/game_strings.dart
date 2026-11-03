import '../features/world/controllers/world_controller.dart';
import '../features/world/world_region.dart';

abstract final class GameStrings {
  static const appTitle = 'Immortal Cultivation';
  static const regionLabel = 'Bản đồ vùng';
  static const regionName = 'Thanh Khê';
  static const mapDescription = 'Thung lũng nhìn từ trên cao, với sông, rừng và núi';
  static const alreadyHere = 'Đang ở đây';
  static const journal = 'Nhật ký';
  static const emptyJournal = 'Chưa có hành trình nào.';
  static const closeDestination = 'Đóng thông tin địa điểm';
  static const zoomIn = 'Phóng to bản đồ';
  static const zoomOut = 'Thu nhỏ bản đồ';

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

  static const floodTitle = 'Nước dâng ven đường';
  static const floodDescription =
      'Nước sông dâng qua bãi cạn. Bạn có thể chờ nước rút hoặc men theo bờ tìm lối vòng.';
  static const floodImageDescription = 'Nước phủ lối đá qua sông ở Bến Hợp Lưu';

  static String floodAction(FloodChoice choice) => switch (choice) {
    FloodChoice.wait => 'Chờ nước rút',
    FloodChoice.detour => 'Men theo bờ tìm lối vòng',
  };

  static String daoNiemName(DaoNiem daoNiem) => switch (daoNiem) {
    DaoNiem.patience => 'Nhẫn Nại',
    DaoNiem.adaptability => 'Ứng Biến',
  };

  static String floodOption(FloodChoice choice) =>
      '${floodAction(choice)} · +${choice.extraHours} giờ\n'
      'Đạo Niệm ${daoNiemName(choice.daoNiem)}';

  static String travelLogDetail(TravelEntry entry) {
    final time = clock(entry.day, entry.hour);
    final choice = entry.floodChoice;
    if (choice == null) return time;

    return '$time\n$floodTitle · ${floodAction(choice)}\n'
        'Nhận Đạo Niệm ${daoNiemName(choice.daoNiem)}';
  }
}
