import '../models/customer.dart';
import '../models/delivery_partner.dart';
import '../models/product.dart';

class MenuData {
  MenuData._();

  static const categories = [
    'Show All',
    'Starters',
    'Pizza',
    'Burger',
    'Sandwich',
    'Pasta',
    'Hot Beverages',
    'Cold Beverages',
  ];

  static const waiters = [
    'Select Waiter',
    'Rahul Sharma',
    'Priya Singh',
    'Amit Kumar',
    'Neha Patel',
  ];

  static const creditCustomers = [
    CreditCustomer(
      id: 'c1',
      name: 'Risala KM',
      phone: '98470112',
      outstanding: 1850,
    ),
    CreditCustomer(
      id: 'c2',
      name: 'Abdul Murad',
      phone: '98601445',
      outstanding: 620,
    ),
    CreditCustomer(
      id: 'c3',
      name: 'Nafees',
      phone: '98712778',
      outstanding: 0,
    ),
    CreditCustomer(
      id: 'c4',
      name: 'Hosne Mubarak',
      phone: '98823990',
      outstanding: 1340,
    ),
  ];

  static const deliveryPartners = [
    DeliveryPartner(id: 'd1', name: 'Rafeek'),
    DeliveryPartner(id: 'd2', name: 'Keeta'),
    DeliveryPartner(id: 'd3', name: 'Snoonu'),
    DeliveryPartner(id: 'd4', name: 'Talabat'),
  ];

  static const products = [
    Product(
      id: '1',
      name: 'Veg Spring Roll',
      price: 80,
      category: 'Starters',
      imageUrl:
          'https://images.unsplash.com/photo-1606525437670-3b821b5ea327?w=500&q=80',
    ),
    Product(
      id: '2',
      name: 'French Fries',
      price: 80,
      category: 'Starters',
      imageUrl:
          'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?w=500&q=80',
    ),
    Product(
      id: '3',
      name: 'Veg Manchurian',
      price: 150,
      category: 'Starters',
      imageUrl:
          'https://images.unsplash.com/photo-1626804475297-54192de37946?w=500&q=80',
    ),
    Product(
      id: '4',
      name: 'Honey Chilli Potato',
      price: 150,
      category: 'Starters',
      imageUrl:
          'https://images.unsplash.com/photo-1518013431117-eb1465fa5752?w=500&q=80',
    ),
    Product(
      id: '5',
      name: 'Cheese Balls',
      price: 150,
      category: 'Starters',
      imageUrl:
          'https://images.unsplash.com/photo-1541745537411-b8046dc6d66c?w=500&q=80',
    ),
    Product(
      id: '6',
      name: 'Paneer Tikka',
      price: 180,
      category: 'Starters',
      imageUrl:
          'https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?w=500&q=80',
    ),
    Product(
      id: '7',
      name: 'Hara Bhara Kabab',
      price: 180,
      category: 'Starters',
      imageUrl:
          'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=500&q=80',
    ),
    Product(
      id: '8',
      name: 'Veg Seekh Kabab',
      price: 180,
      category: 'Starters',
      imageUrl:
          'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500&q=80',
    ),
    Product(
      id: '9',
      name: 'Chicken Tikka',
      price: 220,
      category: 'Starters',
      imageUrl:
          'https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?w=500&q=80',
      isVeg: false,
    ),
    Product(
      id: '10',
      name: 'Fish Fingers',
      price: 250,
      category: 'Starters',
      imageUrl:
          'https://images.unsplash.com/photo-1544943910-4c1dc44aab44?w=500&q=80',
      isVeg: false,
    ),
    Product(
      id: '11',
      name: 'Margherita Pizza',
      price: 250,
      category: 'Pizza',
      imageUrl:
          'https://images.unsplash.com/photo-1574071318508-1cdbab80d002?w=500&q=80',
    ),
    Product(
      id: '12',
      name: 'Farmhouse Pizza',
      price: 320,
      category: 'Pizza',
      imageUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=500&q=80',
    ),
    Product(
      id: '13',
      name: 'Pepperoni Pizza',
      price: 380,
      category: 'Pizza',
      imageUrl:
          'https://images.unsplash.com/photo-1628840042765-356cda07504e?w=500&q=80',
      isVeg: false,
    ),
    Product(
      id: '14',
      name: 'BBQ Chicken Pizza',
      price: 400,
      category: 'Pizza',
      imageUrl:
          'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500&q=80',
      isVeg: false,
    ),
    Product(
      id: '15',
      name: 'Veg Burger',
      price: 120,
      category: 'Burger',
      imageUrl:
          'https://images.unsplash.com/photo-1550547660-d9450f859349?w=500&q=80',
    ),
    Product(
      id: '16',
      name: 'Chicken Burger',
      price: 150,
      category: 'Burger',
      imageUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=500&q=80',
      isVeg: false,
    ),
    Product(
      id: '17',
      name: 'Cheese Burger',
      price: 160,
      category: 'Burger',
      imageUrl:
          'https://images.unsplash.com/photo-1572802419224-296b0aeee0d9?w=500&q=80',
    ),
    Product(
      id: '18',
      name: 'Club Sandwich',
      price: 140,
      category: 'Sandwich',
      imageUrl:
          'https://images.unsplash.com/photo-1528735602780-2552fd46c7af?w=500&q=80',
    ),
    Product(
      id: '19',
      name: 'Grilled Sandwich',
      price: 110,
      category: 'Sandwich',
      imageUrl:
          'https://images.unsplash.com/photo-1481070414801-51fd732d7184?w=500&q=80',
    ),
    Product(
      id: '20',
      name: 'Chicken Sandwich',
      price: 160,
      category: 'Sandwich',
      imageUrl:
          'https://images.unsplash.com/photo-1553909489-cd47e0907980?w=500&q=80',
      isVeg: false,
    ),
    Product(
      id: '21',
      name: 'White Sauce Pasta',
      price: 220,
      category: 'Pasta',
      imageUrl:
          'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?w=500&q=80',
    ),
    Product(
      id: '22',
      name: 'Red Sauce Pasta',
      price: 200,
      category: 'Pasta',
      imageUrl:
          'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=500&q=80',
    ),
    Product(
      id: '23',
      name: 'Chicken Alfredo',
      price: 280,
      category: 'Pasta',
      imageUrl:
          'https://images.unsplash.com/photo-1645112411341-6c4fd023714a?w=500&q=80',
      isVeg: false,
    ),
    Product(
      id: '24',
      name: 'Masala Chai',
      price: 40,
      category: 'Hot Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1571934811356-5cc061b6821f?w=500&q=80',
    ),
    Product(
      id: '25',
      name: 'Cappuccino',
      price: 120,
      category: 'Hot Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1572442388796-11668a67e53d?w=500&q=80',
    ),
    Product(
      id: '26',
      name: 'Hot Chocolate',
      price: 140,
      category: 'Hot Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1542990253-0d0f5be5f0ed?w=500&q=80',
    ),
    Product(
      id: '27',
      name: 'Fresh Lime Soda',
      price: 60,
      category: 'Cold Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=500&q=80',
    ),
    Product(
      id: '28',
      name: 'Cold Coffee',
      price: 130,
      category: 'Cold Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?w=500&q=80',
    ),
    Product(
      id: '29',
      name: 'Mango Smoothie',
      price: 150,
      category: 'Cold Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1505252585461-04c0e4c2430c?w=500&q=80',
    ),
    Product(
      id: '30',
      name: 'Iced Tea',
      price: 80,
      category: 'Cold Beverages',
      imageUrl:
          'https://images.unsplash.com/photo-1556679343-c7306c1976bc?w=500&q=80',
    ),
  ];
}
