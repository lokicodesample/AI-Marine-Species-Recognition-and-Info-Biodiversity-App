import 'creature_model.dart';

class CreatureData {
  static final Map<String, Creature> _data = {
    'Clams': Creature(
      name: 'Clams',
      averageHeight: '5-15 cm',
      averageWeight: '0.1-0.5 kg',
      habitat: 'Sandy ocean floors',
      edibility: 'Edible (cooked)',
      diet: 'Plankton, algae',
      conservationStatus: 'Least Concern',
      imagePath: 'assets/sea_creatures/clams.jpg',
    ),

    'Dolphin': Creature(
      name: 'Dolphin',
      averageHeight: '2-4 m',
      averageWeight: '150-650 kg',
      habitat: 'Open oceans',
      edibility: 'Protected species',
      diet: 'Fish, squid',
      conservationStatus: 'Varies by species',
      imagePath: 'assets/sea_creatures/dolphin.jpg',
    ),
    // Add remaining 21 creatures following this pattern

  };

  static Creature? getCreature(String name) => _data[name];
}