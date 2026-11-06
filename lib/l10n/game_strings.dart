import '../features/cultivation/cultivation_state.dart';
import '../features/world/controllers/world_controller.dart';
import '../features/world/world_region.dart';

abstract final class GameStrings {
  static const appTitle = 'Immortal Cultivation';
  static const loadingSave = 'Đang tải tiến độ';
  static const loadFailed = 'Không đọc được tiến độ đã lưu.';
  static const saveFailed = 'Chưa lưu được tiến độ.';
  static const retry = 'Thử lại';
  static const regionLabel = 'Bản đồ vùng';
  static const regionName = 'Thanh Khê';
  static const mapDescription =
      'Thung lũng nhìn từ trên cao, với sông, rừng và núi';
  static const alreadyHere = 'Đang ở đây';
  static const journal = 'Nhật ký';
  static const emptyJournal = 'Nhật ký còn trống.';
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
      'Nước sông dâng ngập lối dẫn lên cầu gỗ. Bạn có thể chờ nước rút hoặc men theo bờ tìm lối vòng.';
  static const floodImageDescription =
      'Nước dâng phủ lối qua sông tại Thanh Khê';

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

  static String journalDetail(JournalEntry entry) {
    final time = clock(entry.day, entry.hour);
    final choice = entry.floodChoice;
    if (choice == null) return time;

    return '$time\n$floodTitle · ${floodAction(choice)}\n'
        'Nhận Đạo Niệm ${daoNiemName(choice.daoNiem)}';
  }

  static const cultivation = 'Bế quan';
  static const cultivationAtCave = 'Trở về Động Phủ để bế quan và đột phá.';
  static const breakthrough = 'Đột phá';
  static const firstBreakthroughComplete = 'Đã đột phá lên Luyện Khí.';
  static const noInsight = 'Chưa có Đạo Niệm';

  static String realmName(CultivationRealm realm) => switch (realm) {
    CultivationRealm.mortal => 'Phàm Nhân',
    CultivationRealm.qiRefining => 'Luyện Khí',
  };

  static String cultivationProgress(int progress) => 'Tu vi · $progress';
  static String retreatAction(int hours, int gain) =>
      'Bế quan $hours giờ · +$gain tu vi';

  static String ownedInsights(Iterable<DaoNiem> insights) => insights.isEmpty
      ? noInsight
      : 'Đạo Niệm · ${insights.map(daoNiemName).join(', ')}';

  static String breakthroughOption(
    DaoNiem? insight,
    int cost,
  ) => switch (insight) {
    null => 'Đột phá thường · $cost tu vi',
    DaoNiem.patience => 'Nhẫn Nại · $cost tu vi',
    DaoNiem.adaptability =>
      'Ứng Biến · $cost tu vi\nNhận lại ${CultivationState.adaptabilityBonus} tu vi sau đột phá',
  };

  static const character = 'Nhân vật';
  static const characterRealm = 'Cảnh giới';
  static const characterInsights = 'Đạo Niệm';

  static String characterInsightEffect(DaoNiem insight) => switch (insight) {
    DaoNiem.patience => 'Giảm lượng tu vi cần để đột phá.',
    DaoNiem.adaptability =>
      'Nhận lại ${CultivationState.adaptabilityBonus} tu vi sau đột phá.',
  };

  static const inventory = 'Túi đồ';
  static const emptyInventory = 'Túi đồ còn trống.';
  static const herbUse = 'Dùng khi bế quan tại Động Phủ để tăng thêm tu vi.';

  static String herbCount(int count) => 'Linh thảo × $count';
  static String harvestAction(int hours) => 'Hái linh thảo · $hours giờ';

  static String journalTitle(JournalEntry entry) => switch (entry.kind) {
    JournalKind.travel => arrival(entry.place, entry.hours),
    JournalKind.manual => learnedManual,
    JournalKind.harvest =>
      'Hái linh thảo tại ${placeName(entry.place)} · ${entry.hours} giờ',
  };

  static String herbalRetreat(int herbs, int gain) {
    final hours = CultivationState.retreatHours;
    return 'Bế quan với 1 linh thảo · $hours giờ · +$gain tu vi\n'
        'Đang có $herbs linh thảo';
  }

  static const characterManual = 'Công pháp';
  static const manualName = 'Thanh Khê Dưỡng Khí Quyết';
  static const learnedManual = 'Đã học Thanh Khê Dưỡng Khí Quyết';

  static String surveyPass(int hours) => 'Khảo sát đèo · $hours giờ';
  static String manualEffect(int bonus) => '+$bonus tu vi mỗi lượt bế quan.';

  static const walkingRoute = 'Quan lộ';
  static const routeDetails = 'Chi tiết lộ trình';
  static const resumeJourney = 'Xử lý biến cố để tiếp tục';
  static const journeyInterrupted = 'Hành trình đang tạm dừng ở điểm vượt sông';
  static const noRouteEvent = 'Không có nguy cơ đã biết.';

  static String routeStep(WorldTrail step) {
    final terrain = switch (step.terrain) {
      TrailTerrain.riverCrossing => 'vượt sông',
      TrailTerrain.mountainPath => 'đường núi',
    };
    return '${placeName(step.from)} → ${placeName(step.to)} · '
        '${step.hours} giờ · $terrain';
  }

  static String routeRisk(double risk) => risk == 0
      ? noRouteEvent
      : 'Nguy cơ nước dâng khoảng ${(risk * 100).round()}% cho cả chuyến.';

  static String interruptedProgress(int elapsed, int remaining) =>
      'Đã đi $elapsed giờ · Còn $remaining giờ di chuyển, '
      'chưa tính thời gian xử lý biến cố.';
}
