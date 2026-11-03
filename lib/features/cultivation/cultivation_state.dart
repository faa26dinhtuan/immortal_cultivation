enum DaoNiem { patience, adaptability }

enum CultivationRealm { mortal, qiRefining }

class CultivationState {
  static const retreatHours = 2;
  static const retreatGain = 4;
  static const adaptabilityBonus = 6;

  CultivationRealm _realm = CultivationRealm.mortal;
  int _progress = 0;
  final _insights = <DaoNiem>{};

  CultivationRealm get realm => _realm;
  int get progress => _progress;
  Iterable<DaoNiem> get insights => Set.unmodifiable(_insights);
  bool get hasNextRealm => _realm == CultivationRealm.mortal;

  int requiredProgress(DaoNiem? insight) =>
      insight == DaoNiem.patience ? 8 : 12;

  bool canBreakThrough(DaoNiem? insight) =>
      hasNextRealm &&
      (insight == null || _insights.contains(insight)) &&
      _progress >= requiredProgress(insight);

  void gainInsight(DaoNiem insight) => _insights.add(insight);

  void retreat() => _progress += retreatGain;

  bool breakThrough(DaoNiem? insight) {
    if (!canBreakThrough(insight)) return false;

    _progress -= requiredProgress(insight);
    if (insight == DaoNiem.adaptability) _progress += adaptabilityBonus;
    _realm = CultivationRealm.qiRefining;
    return true;
  }
}
