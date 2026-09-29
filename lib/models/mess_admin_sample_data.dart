class MessAdminSampleData {
  static const int vegPrice = 90;
  static const int nonVegPrice = 110;

  static const List<Map<String, String>> vegStudents = [
    {'name': 'Nanditha', 'room': '2115'},
    {'name': 'Aisha', 'room': '2112'},
    {'name': 'Priya', 'room': '2006'},
    {'name': 'Sneha', 'room': '2114'},
  ];

  static const List<Map<String, String>> nonVegStudents = [
    {'name': 'Revathy', 'room': '2107'},
    {'name': 'Anika', 'room': '2108'},
    {'name': 'Nashva', 'room': '2109'},
  ];

  static const List<Map<String, String>> weeklyMenu = [
    {
      'day': 'Monday',
      'breakfast': 'Idli + Sambar',
      'lunch': 'Rice + Dal',
      'snack': 'Pazham',
      'dinner': 'Chapati + Curry',
    },
    {
      'day': 'Tuesday',
      'breakfast': 'Dosa',
      'lunch': 'Rice + Sambar',
      'snack': 'Tea + Biscuit',
      'dinner': 'Puttu + Kadala',
    },
    {
      'day': 'Wednesday',
      'breakfast': 'Idiyappam',
      'lunch': 'Rice + Rasam',
      'snack': 'Pazham',
      'dinner': 'Chapati',
    },
    {
      'day': 'Thursday',
      'breakfast': 'Upma',
      'lunch': 'Rice + Dal',
      'snack': 'Tea',
      'dinner': 'Fried Rice',
    },
    {
      'day': 'Friday',
      'breakfast': 'Poori',
      'lunch': 'Veg Biriyani',
      'snack': 'Biscuit',
      'dinner': 'Chapati',
    },
    {
      'day': 'Saturday',
      'breakfast': 'Dosa',
      'lunch': 'Rice + Curry',
      'snack': 'Tea',
      'dinner': 'Noodles',
    },
    {
      'day': 'Sunday',
      'breakfast': 'Idli',
      'lunch': 'Special Meals',
      'snack': 'Juice',
      'dinner': 'Chapati',
    },
  ];

  static const List<Map<String, String>> dutyAllocation = [
    {'date': '02/01/26', 'evening': '2108', 'night': '2109'},
    {'date': '02/02/26', 'evening': '2110', 'night': '2111'},
    {'date': '02/03/26', 'evening': '2112', 'night': '2113'},
    {'date': '02/04/26', 'evening': '2114', 'night': '2115'},
    {'date': '02/05/26', 'evening': '2116', 'night': '2117'},
    {'date': '02/06/26', 'evening': '2118', 'night': '2119'},
    {'date': '02/07/26', 'evening': '2120', 'night': '2121'},
    {'date': '02/08/26', 'evening': '2122', 'night': '2123'},
    {'date': '02/09/26', 'evening': '2124', 'night': '2125'},
    {'date': '02/10/26', 'evening': '2126', 'night': '2127'},
    {'date': '02/11/26', 'evening': '2128', 'night': '2129'},
    {'date': '02/12/26', 'evening': '2130', 'night': '2131'},
  ];

  static int totalBill({int? vegUnitPrice, int? nonVegUnitPrice}) {
    final vegUnit = vegUnitPrice ?? vegPrice;
    final nonVegUnit = nonVegUnitPrice ?? nonVegPrice;
    return (vegStudents.length * vegUnit) +
        (nonVegStudents.length * nonVegUnit);
  }
}
