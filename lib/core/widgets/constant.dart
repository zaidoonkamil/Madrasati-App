import '../ navigation/navigation.dart';
import '../../features/auth/view/login.dart';
import '../network/local/cache_helper.dart';

String token='';
String id='';
String adminOrUser='' ;
String phoneWoner='7736699924' ;
String logo='logomadrasaty.png' ;
String appShareLink='logomadrasaty.png' ;
String nameApp='طكة ناقص - ارخص الاسعار' ;


void signOut(context) {
  CacheHelper.removeData(
    key: 'token',
  ).then((value)
  {
    token='';
    adminOrUser='' ;
    id='' ;
    if (value)
    {
      CacheHelper.removeData(key: 'role',);
      CacheHelper.removeData(key: 'id',);
      navigateTo(context, const Login(),);
    }
  });
}
