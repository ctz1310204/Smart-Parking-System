import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'screens/wrapper.dart';
import 'blocs/auth/auth_cubit.dart';
import 'blocs/parking_lot/parking_lot_cubit.dart'; // Import ParkingLotCubit
import 'package:firebase_auth/firebase_auth.dart';
import 'services/firebase_db_service.dart'; // Import Service

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Khởi tạo Service Firebase DB
  final firebaseDbService = FirebaseDbService();
  // Xác định ID bãi đỗ (ví dụ: 'lot_1')
  final parkingLotId = 'lot_1';

  runApp(
    MyApp(firebaseDbService: firebaseDbService, parkingLotId: parkingLotId),
  );
}

class MyApp extends StatelessWidget {
  final FirebaseDbService firebaseDbService;
  final String parkingLotId;

  const MyApp({
    Key? key,
    required this.firebaseDbService,
    required this.parkingLotId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Cung cấp cả AuthCubit và ParkingLotCubit sử dụng MultiBlocProvider
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) => AuthCubit(FirebaseAuth.instance),
        ),
        BlocProvider<ParkingLotCubit>(
          // ParkingLotCubit cần instance của FirebaseDbService và parkingLotId
          create: (context) => ParkingLotCubit(firebaseDbService, parkingLotId),
        ),
      ],
      child: MaterialApp(
        title: 'Smart Parking App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Wrapper(), // Wrapper vẫn là màn hình gốc
      ),
    );
  }
}
