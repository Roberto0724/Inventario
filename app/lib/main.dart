
import 'package:flutter/material.dart';

void main() {
  runApp(const InventarioApp());
}

class InventarioApp extends StatelessWidget {
  const InventarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventario ERP Logistics',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF155E75),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7FA),
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;

  final List<String> sections = [
    'Dashboard',
    'Productos',
    'Almacenes',
    'Movimientos',
    'Logística',
    'Licencias',
  ];

  final List<IconData> sectionIcons = [
    Icons.dashboard_outlined,
    Icons.inventory_2_outlined,
    Icons.warehouse_outlined,
    Icons.swap_horiz,
    Icons.local_shipping_outlined,
    Icons.vpn_key_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 850;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventario ERP Logistics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Notificaciones',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: CircleAvatar(
              child: Icon(Icons.person_outline),
            ),
          ),
        ],
      ),
      drawer: isWide ? null : Drawer(child: buildMenu()),
      body: Row(
        children: [
          if (isWide)
            SizedBox(
              width: 240,
              child: buildMenu(),
            ),
          Expanded(
            child: selectedIndex == 0
                ? buildDashboard()
                : Center(
                    child: Text(
                      sections[selectedIndex],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  
Widget buildMenu() {
  return Material(
    color: const Color(0xFF102A43),
    child: SafeArea(
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'INVENTARIO ERP',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (int i = 0; i < sections.length; i++)
            ListTile(
              leading: Icon(
                sectionIcons[i],
                color: Colors.white70,
              ),
              title: Text(
                sections[i],
                style: const TextStyle(color: Colors.white),
              ),
              selected: selectedIndex == i,
              selectedTileColor: Colors.white12,
              onTap: () {
                setState(() {
                  selectedIndex = i;
                });

                if (MediaQuery.sizeOf(context).width < 850) {
                  Navigator.of(context).pop();
                }
              },
            ),
        ],
      ),
    ),
  );
}


  Widget buildDashboard() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Panel principal',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Resumen general de las operaciones de inventario',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 4
                : constraints.maxWidth >= 500
                    ? 2
                    : 1;

            return GridView.count(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: columns == 1 ? 3.2 : 1.7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                buildStatCard(
                  'Total productos',
                  '0',
                  Icons.inventory_2_outlined,
                  Colors.blue,
                ),
                buildStatCard(
                  'Almacenes',
                  '0',
                  Icons.warehouse_outlined,
                  Colors.green,
                ),
                buildStatCard(
                  'Movimientos',
                  '0',
                  Icons.swap_horiz,
                  Colors.orange,
                ),
                buildStatCard(
                  'Stock bajo',
                  '0',
                  Icons.warning_amber_outlined,
                  Colors.red,
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actividad reciente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Todavía no hay movimientos registrados.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
