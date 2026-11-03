enum DaoNiem { patience, adaptability }

enum CultivationRealm { mortal, qiRefining }

class CultivationState {
  static const retreatHours = 2;
  static const retreatGain = 4;
  static const manualBonus = 1;
  static const herbBonus = 2;
  static const adaptabilityBonus = 6;

  CultivationState({
    CultivationRealm realm = CultivationRealm.mortal,
    int progress = 0,
    bool knowsManual = false,
    Iterable<DaoNiem> insights = const [],
  }) : _realm = realm,
       _progress = progress,
       _knowsManual = knowsManual,
       _insights = insights.toSet();

  CultivationRealm _realm;
  int _progress;
  bool _knowsManual;
  final Set<DaoNiem> _insights;

  CultivationRealm get realm => _realm;
  int get progress => _progress;
  bool get knowsManual => _knowsManual;

  int retreatProgress({bool useHerb = false}) =>
      retreatGain + (_knowsManual ? manualBonus : 0) + (useHerb ? herbBonus : 0);

  void learnManual() => _knowsManual = true;
  Iterable<DaoNiem> get insights => Set.unmodifiable(_insights);
  bool get hasNextRealm => _realm == CultivationRealm.mortal;

  int requiredProgress(DaoNiem? insight) =>
      insight == DaoNiem.patience ? 8 : 12;

  bool canBreakThrough(DaoNiem? insight) =>
      hasNextRealm &&
      (insight == null || _insights.contains(insight)) &&
      _progress >= requiredProgress(insight);

  void gainInsight(DaoNiem insight) => _insights.add(insight);

  void retreat({bool useHerb = false}) {
    _progress += retreatProgress(useHerb: useHerb);
  }

  bool breakThrough(DaoNiem? insight) {
    if (!canBreakThrough(insight)) return false;

    _progress -= requiredProgress(insight);
    if (insight == DaoNiem.adaptability) _progress += adaptabilityBonus;
    _realm = CultivationRealm.qiRefining;
    return true;
  }
}
