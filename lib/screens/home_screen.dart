import 'package:flutter/material.dart';
import '../widgets/chat_drawer.dart';
import 'chat_screen.dart';
import 'api_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.of(context).pop(); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: ChatDrawer(
        selectedIndex: _selectedIndex,
        onSelect: _onItemSelected,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          ChatScreen(title: 'Bot Chat'),
          ApiChatScreen(title: 'API Chat'),
        ],
      ),
    );
  }
}