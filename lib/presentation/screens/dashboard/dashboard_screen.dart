import 'package:billing_app_flutter/db/models/customer_entity.dart';
import 'package:billing_app_flutter/db/models/sale_entry_entity.dart';
import 'package:billing_app_flutter/presentation/screens/sale_entry/sale_entry_screen.dart';
import 'package:billing_app_flutter/presentation/widgets/drawer_menu_widget.dart';
import 'package:billing_app_flutter/presentation/widgets/menubar_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:menu_bar/menu_bar.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    return MenuBarWidget(
      barButtons: menuBarButtons(),
      // Style the menu bar itself. Hover over [MenuStyle] for all the options
      barStyle: const MenuStyle(
        padding: MaterialStatePropertyAll(EdgeInsets.all(4)),
        backgroundColor: MaterialStatePropertyAll(Color(0xFF2b2b2b)),
        maximumSize: MaterialStatePropertyAll(Size(double.infinity, 28.0)),
      ),
      // Style the menu bar buttons. Hover over [ButtonStyle] for all the options
      barButtonStyle: const ButtonStyle(
        padding:
        MaterialStatePropertyAll(EdgeInsets.symmetric(horizontal: 8.0)),
        minimumSize: MaterialStatePropertyAll(Size(0.0, 40.0)),
      ),
      // Style the menu and submenu buttons. Hover over [ButtonStyle] for all the options
      menuButtonStyle: const ButtonStyle(
        minimumSize: MaterialStatePropertyAll(Size.fromHeight(36.0)),
        padding: MaterialStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0)),
      ),
      // Enable or disable the bar
      enabled: true,

      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Text(
                "Codweb's",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              Text(
                ' Billing Software',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.primaryContainer,
          elevation: 2,
          iconTheme: IconThemeData(color: theme.colorScheme.onPrimaryContainer),
          actions: [
            IconButton(onPressed: (){
              Get.to(SaleEntryScreen(invoiceEntity: SaleEntryEntity()));
            }, icon: Icon(Icons.ac_unit))
          ],
        ),
        drawer: DrawerMenuWidget(),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
                const SizedBox(height: 16),
      
                // First Row - Responsive layout
                if (isSmallScreen) ...[
                  _buildRankingsCard(context),
                  const SizedBox(height: 16),
                  _buildAnalyticsCard(context),
                ] else if (isMediumScreen) ...[
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildRankingsCard(context)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildAnalyticsCard(context)),
                        ],
                      ),
                    ],
                  )
                ] else ...[
                  Row(
                    children: [
                      Expanded(flex: 2, child: _buildRankingsCard(context)),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: _buildAnalyticsCard(context)),
                    ],
                  ),
                ],
      
                const SizedBox(height: 16),
      
                // Second Row - Responsive layout
                if (isSmallScreen) ...[
                  _buildLighthouseCard(context),
                  const SizedBox(height: 16),
                  _buildSessionsCard(context),
                  const SizedBox(height: 16),
                  _buildBacklinksCard(context),
                ] else if (isMediumScreen) ...[
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: _buildLighthouseCard(context)),
                          const SizedBox(width: 16),
                          Expanded(child: _buildSessionsCard(context)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildBacklinksCard(context),
                    ],
                  )
                ] else ...[
                  Row(
                    children: [
                      Expanded(flex: 1, child: _buildLighthouseCard(context)),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: _buildSessionsCard(context)),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: _buildBacklinksCard(context)),
                    ],
                  ),
                ],
      
                const SizedBox(height: 16),
      
                // Third Row
                _buildSearchConsoleCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankingsCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 400;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rankings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                isSmall
                    ? Column(
                  children: [
                    _buildMetricCard(context, 'Rankings', '10', theme.colorScheme.primary),
                    const SizedBox(height: 8),
                    _buildMetricCard(context, 'Change', '4', theme.colorScheme.tertiary),
                    const SizedBox(height: 8),
                    _buildMetricCard(context, 'Rankings', '8', theme.colorScheme.primary),
                  ],
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMetricCard(context, 'Rankings', '10', theme.colorScheme.primary),
                    _buildMetricCard(context, 'Change', '4', theme.colorScheme.tertiary),
                    _buildMetricCard(context, 'Rankings', '8', theme.colorScheme.primary),
                  ],
                ),

                const SizedBox(height: 22),

                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        horizontalInterval: 3,
                        verticalInterval: 1,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                        getDrawingVerticalLine: (value) => FlLine(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              final dates = [
                                '16 Oct',
                                '22 Oct',
                                '26 Oct',
                                '30 Oct',
                                '4 Nov',
                                '9 Nov',
                                '12 Nov',
                                '15 Nov',
                              ];
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  dates[value.toInt() % dates.length],
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                                ),
                              );
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(
                          color: theme.colorScheme.outline.withOpacity(0.2),
                        ),
                      ),
                      minX: 0,
                      maxX: 7,
                      minY: 0,
                      maxY: 15,
                      lineBarsData: [
                        LineChartBarData(
                          spots: const [
                            FlSpot(0, 10),
                            FlSpot(1, 8),
                            FlSpot(2, 12),
                            FlSpot(3, 9),
                            FlSpot(4, 7),
                            FlSpot(5, 5),
                            FlSpot(6, 6),
                            FlSpot(7, 4),
                          ],
                          isCurved: true,
                          color: theme.colorScheme.primary,
                          barWidth: 3,
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.colorScheme.primary.withOpacity(0.1),
                          ),
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) =>
                                FlDotCirclePainter(
                                  radius: 4,
                                  color: theme.colorScheme.primary,
                                  strokeWidth: 2,
                                  strokeColor: theme.colorScheme.onPrimary,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goodje Analytics',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Column(
              children: [
                _buildAnalyticsItem(context, 'Referral', '602', theme.colorScheme.primary),
                _buildAnalyticsItem(context, 'Organic Search', '573', theme.colorScheme.secondary),
                _buildAnalyticsItem(context, 'Direct', '564', theme.colorScheme.tertiary),
                _buildAnalyticsItem(context, 'Other', '410', theme.colorScheme.error),
                _buildAnalyticsItem(context, 'Pad Search', '212', theme.colorScheme.primaryContainer),
                _buildAnalyticsItem(context, 'Social', '178', theme.colorScheme.secondaryContainer),
                _buildAnalyticsItem(context, 'Display', '126', theme.colorScheme.tertiaryContainer),
                _buildAnalyticsItem(context, 'Email', '122', theme.colorScheme.errorContainer),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLighthouseCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Goodje Lighthouse',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 40,
                        sections: [
                          PieChartSectionData(
                            value: 70,
                            color: theme.colorScheme.primary,
                            radius: 25,
                            title: '70%',
                            titleStyle: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          PieChartSectionData(
                            value: 30,
                            color: theme.colorScheme.surfaceVariant,
                            radius: 25,
                            showTitle: false,
                          ),
                        ],
                        startDegreeOffset: -90,
                      ),
                    ),
                    Text(
                      '70%',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 200) {
                  return Column(
                    children: [
                      _buildSmallScore(context, 'SEO Score', '40', theme.colorScheme.error),
                      const SizedBox(height: 8),
                      _buildSmallScore(context, 'Accessibility', '80', theme.colorScheme.tertiary),
                      const SizedBox(height: 8),
                      _buildSmallScore(context, 'Best Practices', '90', theme.colorScheme.secondary),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSmallScore(context, 'SEO Score', '40', theme.colorScheme.error),
                      _buildSmallScore(context, 'Accessibility', '80', theme.colorScheme.tertiary),
                      _buildSmallScore(context, 'Best Practices', '90', theme.colorScheme.secondary),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sessions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        sectionsSpace: 0,
                        centerSpaceRadius: 50,
                        sections: [
                          PieChartSectionData(
                            value: 2787,
                            color: theme.colorScheme.primary,
                            radius: 25,
                            title: '84%',
                            titleStyle: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                          PieChartSectionData(
                            value: 519,
                            color: theme.colorScheme.surfaceVariant,
                            radius: 25,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '2,787',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'sessions',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 200) {
                  return Column(
                    children: [
                      _buildSessionMetric(context, 'Goal Completions', '2,787'),
                      const SizedBox(height: 8),
                      _buildSessionMetric(context, 'Total', '3,306'),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSessionMetric(context, 'Goal Completions', '2,787'),
                      const SizedBox(width: 16),
                      _buildSessionMetric(context, 'Total', '3,306'),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBacklinksCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Backlinks',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 300) {
                  return Column(
                    children: [
                      _buildMetricCard(context, 'Citation Flow', '55', theme.colorScheme.tertiary),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          Text(
                            'New/Lost Links',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                margin: const EdgeInsets.only(right: 4),
                              ),
                              Text('New', style: theme.textTheme.bodySmall),
                              const SizedBox(width: 8),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                margin: const EdgeInsets.only(right: 4),
                              ),
                              Text('Lost', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricCard(context, 'Citation Flow', '55', theme.colorScheme.tertiary),
                      Column(
                        children: [
                          Text(
                            'New/Lost Links',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiary,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                margin: const EdgeInsets.only(right: 4),
                              ),
                              Text('New', style: theme.textTheme.bodySmall),
                              const SizedBox(width: 8),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.error,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                margin: const EdgeInsets.only(right: 4),
                              ),
                              Text('Lost', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 20,
                  minY: -10,
                  groupsSpace: 10,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final dates = ['Apr 5', 'Apr 12', 'Apr 19', 'Apr 26'];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              dates[value.toInt()],
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.2),
                    ),
                  ),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barsSpace: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 12,
                          color: theme.colorScheme.tertiary,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        BarChartRodData(
                          toY: -4,
                          color: theme.colorScheme.error,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barsSpace: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 8,
                          color: theme.colorScheme.tertiary,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        BarChartRodData(
                          toY: -6,
                          color: theme.colorScheme.error,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barsSpace: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 15,
                          color: theme.colorScheme.tertiary,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        BarChartRodData(
                          toY: -3,
                          color: theme.colorScheme.error,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barsSpace: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 10,
                          color: theme.colorScheme.tertiary,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        BarChartRodData(
                          toY: -7,
                          color: theme.colorScheme.error,
                          width: 8,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchConsoleCard(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Google Search Console',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 500) {
                  return Column(
                    children: [
                      _buildMetricCard(context, 'Impressions', '262 K', theme.colorScheme.primary),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 100,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: false),
                            titlesData: FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            minX: 0,
                            maxX: 29,
                            minY: 0,
                            maxY: 150,
                            lineBarsData: [
                              LineChartBarData(
                                spots: List.generate(
                                  30,
                                      (index) => FlSpot(
                                    index.toDouble(),
                                    50 + (index % 10) * 10,
                                  ),
                                ),
                                isCurved: true,
                                color: theme.colorScheme.primary,
                                barWidth: 2,
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: theme.colorScheme.primary.withOpacity(0.1),
                                ),
                                dotData: FlDotData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    children: [
                      _buildMetricCard(context, 'Impressions', '262 K', theme.colorScheme.primary),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 100,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              minX: 0,
                              maxX: 29,
                              minY: 0,
                              maxY: 150,
                              lineBarsData: [
                                LineChartBarData(
                                  spots: List.generate(
                                    30,
                                        (index) => FlSpot(
                                      index.toDouble(),
                                      50 + (index % 10) * 10,
                                    ),
                                  ),
                                  isCurved: true,
                                  color: theme.colorScheme.primary,
                                  barWidth: 2,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: theme.colorScheme.primary.withOpacity(0.1),
                                  ),
                                  dotData: FlDotData(show: false),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget methods
  Widget _buildMetricCard(BuildContext context, String title, String value, Color color) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
            margin: const EdgeInsets.only(right: 8),
          ),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallScore(BuildContext context, String label, String value, Color color) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionMetric(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}