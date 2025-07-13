import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_notifier.dart';
import '../theme/app_colors.dart';
import '../utils/admin_config.dart';
import 'artists_screen.dart';
import 'reads_screen.dart';
import 'admin_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tapCount = 0;
  DateTime? _lastTapTime;

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'الفنانين',
      'icon': Icons.people,
      'image': 'assets/images/artists_category.png',
      'color': Colors.blue,
      'screen': ArtistsScreen(),
    },
    {
      'title': 'القران الكريم',
      'icon': Icons.new_releases,
      'image': 'assets/images/quran.jpg',
      'color': Colors.green,
      'screen': ReadersScreen(),
    },
    {
      'title': 'الأحدث',
      'icon': Icons.new_releases,
      'image': 'assets/images/latest_category.png',
      'color': Colors.green,
      'screen': ArtistsScreen(),
    },
    {
      'title': 'المفضلة',
      'icon': Icons.favorite,
      'image': 'assets/images/favorites_category.png',
      'color': Colors.red,
      'screen': ArtistsScreen(),
    },
    {
      'title': 'التصنيفات',
      'icon': Icons.category,
      'image': 'assets/images/categories_category.png',
      'color': Colors.orange,
      'screen': ArtistsScreen(),
    },
  ];

  void _handleTitleTap() {
    final now = DateTime.now();
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!).inMilliseconds >
            AdminConfig.tapTimeWindow) {
      _tapCount = 1;
    } else {
      _tapCount++;
    }
    _lastTapTime = now;

    // الوصول لشاشة الإدارة بعد النقرات المطلوبة
    if (_tapCount >= AdminConfig.requiredTaps) {
      _tapCount = 0;
      _showAdminAccessDialog();
    }
  }

  void _showAdminAccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('الوصول للإدارة'),
        content: Text('هل تريد الوصول لشاشة الإدارة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdminScreen()),
              );
            },
            child: Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _handleTitleTap,
          child: Text(
            'Zwamil',
            style:
                TextStyle(fontFamily: 'Tajawal', fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeNotifier>(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeNotifier>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          physics: BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return _buildCategoryCard(context, categories[index]);
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final iconColor =
        isDarkMode ? category['color'].withOpacity(0.8) : category['color'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.getCardColor(context),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Feedback.forTap(context);
          Navigator.push(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 300),
              pageBuilder: (_, __, ___) => category['screen'],
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    ),
                  ),
                  child: child,
                );
              },
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isDarkMode
                ? LinearGradient(
                    colors: [
                      category['color'].withOpacity(0.1),
                      category['color'].withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // محاولة عرض الصورة أولاً، ثم الأيقونة إذا فشل التحميل
              _buildCategoryImage(category, iconColor),
              SizedBox(height: 12),
              Text(
                category['title'],
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.getTextColor(context),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Tajawal',
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryImage(Map<String, dynamic> category, Color iconColor) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: category['image'] != null
          ? Image.asset(
              category['image'],
              width: 48,
              height: 48,
              errorBuilder: (_, __, ___) =>
                  _buildCategoryIcon(category, iconColor),
            )
          : _buildCategoryIcon(category, iconColor),
    );
  }

  Widget _buildCategoryIcon(Map<String, dynamic> category, Color iconColor) {
    return Icon(category['icon'], size: 32, color: iconColor);
  }
}
