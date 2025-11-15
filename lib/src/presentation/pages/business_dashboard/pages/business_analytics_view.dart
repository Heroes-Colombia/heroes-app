import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/src/domain/services/analytics_service.dart';
import 'package:intl/intl.dart';

@RoutePage()
class BusinessAnalyticsView extends StatefulWidget {
  final String businessId;
  const BusinessAnalyticsView({super.key, required this.businessId});

  @override
  State<BusinessAnalyticsView> createState() => _BusinessAnalyticsViewState();
}

class _BusinessAnalyticsViewState extends State<BusinessAnalyticsView> {
  Map<String, dynamic>? analyticsData;
  Map<String, dynamic>? demographicsData;
  bool isLoading = true;
  String selectedPeriod = '7'; // Default to 7 days

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => isLoading = true);

    final endDate = DateTime.now();
    final startDate = endDate.subtract(
      Duration(days: int.parse(selectedPeriod)),
    );
    final analyticsService = GetIt.instance.get<AnalyticsService>();

    try {
      final analytics = await analyticsService.getBusinessAnalytics(
        businessId: widget.businessId,
        startDate: startDate,
        endDate: endDate,
      );

      final demographics = await analyticsService.getUserDemographics(
        businessId: widget.businessId,
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        // Safely handle the data with proper null checks and type casting
        if (analytics.isNotEmpty) {
          analyticsData = Map<String, dynamic>.from(analytics);
        } else {
          analyticsData = <String, dynamic>{};
        }
        
        if (demographics.isNotEmpty) {
          demographicsData = Map<String, dynamic>.from(demographics);
        } else {
          demographicsData = <String, dynamic>{};
        }
        
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error cargando analíticas: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analíticas del Negocio'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.calendar_month),
            onSelected: (String value) {
              setState(() => selectedPeriod = value);
              _loadAnalytics();
            },
            itemBuilder:
                (BuildContext context) => [
                  const PopupMenuItem(value: '7', child: Text('Últimos 7 días')),
                  const PopupMenuItem(value: '30', child: Text('Últimos 30 días')),
                  const PopupMenuItem(
                    value: '90',
                    child: Text('Últimos 3 meses'),
                  ),
                ],
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : analyticsData == null
              ? const Center(child: Text('No hay datos disponibles'))
              : RefreshIndicator(
                onRefresh: _loadAnalytics,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPeriodHeader(),
                      const SizedBox(height: 24),
                      _buildOverviewCards(theme),
                      const SizedBox(height: 24),
                      _buildUserBehaviorSection(theme),
                      const SizedBox(height: 24),
                      _buildEngagementSection(theme),
                      const SizedBox(height: 24),
                      _buildDemographicsSection(theme),
                      const SizedBox(height: 24),
                      _buildPerformanceInsights(theme),
                      const SizedBox(height: 24),
                      _buildDataPackagePromotion(theme),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildPeriodHeader() {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(
      Duration(days: int.parse(selectedPeriod)),
    );
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Período de Analíticas',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen General',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildMetricCard(
              'Vistas del Negocio',
              analyticsData!['total_views']?.toString() ?? '0',
              Icons.visibility,
              theme.colorScheme.primary,
            ),
            _buildMetricCard(
              'Vistas de Promociones',
              analyticsData!['promotion_views']?.toString() ?? '0',
              Icons.local_offer,
              theme.colorScheme.secondary,
            ),
            _buildMetricCard(
              'Usuarios Únicos',
              analyticsData!['unique_users']?.toString() ?? '0',
              Icons.people,
              theme.colorScheme.tertiary,
            ),
            _buildMetricCard(
              'Tiempo Prom. de Sesión',
              _formatSessionTime(),
              Icons.access_time,
              Colors.green,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEngagementSection(ThemeData theme) {
    final shares = analyticsData!['shares'] ?? 0;
    final redemptions = analyticsData!['redemptions'] ?? 0;
    final contactAttempts = analyticsData!['contact_attempts'] ?? 0;
    final screenshots = analyticsData!['screenshots_taken'] ?? 0;
    final revisits = analyticsData!['revisits'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Compromiso del Usuario',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildEngagementRow('Intentos de Contacto', contactAttempts, Icons.phone),
                const Divider(height: 24),
                _buildEngagementRow('Revisitas al Negocio', revisits, Icons.repeat),
                const Divider(height: 24),
                _buildEngagementRow('Promociones Compartidas', shares, Icons.share),
                const Divider(height: 24),
                _buildEngagementRow('Capturas de Pantalla', screenshots, Icons.camera_alt),
                const Divider(height: 24),
                _buildEngagementRow(
                  'Promociones Redimidas',
                  redemptions,
                  Icons.redeem,
                ),
                if (contactAttempts > 0 || shares > 0 || redemptions > 0) ...[
                  const Divider(height: 24),
                  _buildEngagementInsight(shares, redemptions, contactAttempts, screenshots),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEngagementRow(String label, int value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEngagementInsight(int shares, int redemptions, int contactAttempts, int screenshots) {
    final promotionViews = analyticsData!['promotion_views'] ?? 1;
    final totalViews = analyticsData!['total_views'] ?? 1;
    final shareRate = (shares / promotionViews * 100).toStringAsFixed(1);
    final redeemRate = (redemptions / promotionViews * 100).toStringAsFixed(1);
    final contactRate = (contactAttempts / totalViews * 100).toStringAsFixed(1);
    final screenshotRate = (screenshots / promotionViews * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tasas de Compromiso',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text('Tasa de Contacto: $contactRate%'),
          Text('Tasa de Capturas: $screenshotRate%'),
          Text('Tasa de Compartir: $shareRate%'),
          Text('Tasa de Redención: $redeemRate%'),
        ],
      ),
    );
  }

  Widget _buildDemographicsSection(ThemeData theme) {
    if (demographicsData == null || demographicsData!.isEmpty) {
      return const SizedBox.shrink();
    }

    final userTypes = _safeMapCast(demographicsData!['user_types']);
    final ranks = _safeMapCast(demographicsData!['ranks']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Demografía de Usuarios',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (userTypes.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipos de Usuario',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...userTypes.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatUserType(entry.key)),
                          Text(
                            '${entry.value}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (ranks.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Rangos Militares',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  ...ranks.entries
                      .take(5)
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  entry.key,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  if (ranks.length > 5)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        '... y más',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDataPackagePromotion(ThemeData theme) {
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  'Analíticas Avanzadas Disponibles',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Obten insights más profundos de tus clientes con nuestros paquetes premium de analíticas:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Patrones detallados de comportamiento del cliente\n'
              '• Análisis de la competencia\n'
              '• Dashboard de analíticas en tiempo real\n'
              '• Reportes personalizados e insights',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Desde \$200,000 COP/mes',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Contacta soporte para paquetes premium de analíticas',
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: const Text('Saber Más'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBehaviorSection(ThemeData theme) {
    final totalViews = analyticsData!['total_views'] ?? 0;
    final uniqueUsers = analyticsData!['unique_users'] ?? 1;
    final favorites = analyticsData!['favorites_added'] ?? 0;
    final revisits = analyticsData!['revisits'] ?? 0;
    final searchConversions = analyticsData!['search_conversions'] ?? 0;
    
    // Calculate real engagement metrics
    final returnVisitorRate = uniqueUsers > 0 ? (revisits / uniqueUsers * 100) : 0;
    final favoriteRate = totalViews > 0 ? (favorites / totalViews * 100) : 0;
    final searchConversionRate = totalViews > 0 ? (searchConversions / totalViews * 100) : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights de Comportamiento del Usuario',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildBehaviorRow(
                  'Tasa de Visitantes que Regresan', 
                  '${returnVisitorRate.toStringAsFixed(1)}%', 
                  Icons.repeat,
                  'Usuarios que revisitaron tu negocio'
                ),
                const Divider(height: 24),
                _buildBehaviorRow(
                  'Tasa de Favoritos', 
                  '${favoriteRate.toStringAsFixed(1)}%', 
                  Icons.favorite_border,
                  'Vistas que resultaron en favoritos'
                ),
                const Divider(height: 24),
                _buildBehaviorRow(
                  'Tasa de Conversión de Búsqueda', 
                  '${searchConversionRate.toStringAsFixed(1)}%', 
                  Icons.search,
                  'Búsquedas que llevaron a vistas del negocio'
                ),
                const Divider(height: 24),
                _buildBehaviorRow(
                  'Tiempo Prom. de Sesión', 
                  _formatSessionTime(), 
                  Icons.schedule,
                  'Tiempo promedio que los usuarios pasan por visita'
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBehaviorRow(String label, String value, IconData icon, String description) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceInsights(ThemeData theme) {
    final totalViews = analyticsData!['total_views'] ?? 0;
    final promotionViews = analyticsData!['promotion_views'] ?? 0;
    final uniqueUsers = analyticsData!['unique_users'] ?? 1;
    
    // Calculate performance metrics
    final viewsPerUser = totalViews / uniqueUsers;
    final promotionEngagement = totalViews > 0 ? (promotionViews / totalViews) : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Insights de Rendimiento',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.4,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildInsightCard(
              'Vistas por Usuario',
              viewsPerUser.toStringAsFixed(1),
              'Visitas promedio por cliente',
              Colors.blue,
            ),
            _buildInsightCard(
              'Tasa de Promociones',
              '${(promotionEngagement * 100).toStringAsFixed(1)}%',
              'Usuarios viendo promociones',
              Colors.orange,
            ),
            _buildInsightCard(
              'Tasa de Descubrimiento',
              _calculateDiscoveryRate(),
              'Usuarios nuevos vs recurrentes',
              Colors.green,
            ),
            _buildInsightCard(
              'Puntuación de Compromiso',
              _calculateEngagementScore(),
              'Compromiso general del usuario',
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightCard(String title, String value, String subtitle, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 4,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                subtitle,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatSessionTime() {
    final avgSessionTimeMinutes = analyticsData!['avg_session_time_minutes'] as double? ?? 0;
    
    if (avgSessionTimeMinutes < 1) {
      final seconds = (avgSessionTimeMinutes * 60).round();
      return '${seconds}s';
    } else if (avgSessionTimeMinutes < 60) {
      return '${avgSessionTimeMinutes.toStringAsFixed(1)}min';
    } else {
      final hours = avgSessionTimeMinutes ~/ 60;
      final mins = (avgSessionTimeMinutes % 60).round();
      return '${hours}h ${mins}m';
    }
  }

  String _calculateDiscoveryRate() {
    // New user discovery rate calculation
    final totalViews = analyticsData!['total_views'] ?? 0;
    final uniqueUsers = analyticsData!['unique_users'] ?? 0;
    
    // Avoid division by zero
    if (totalViews == 0) {
      return '0%';
    }
    
    // Estimate new user rate: unique users as percentage of total views
    final newUserRate = (uniqueUsers / totalViews * 100).clamp(0.0, 100.0);
    return '${newUserRate.toStringAsFixed(0)}%';
  }

  String _calculateEngagementScore() {
    // Calculate engagement score based on multiple factors
    final totalViews = analyticsData!['total_views'] ?? 0;
    final favorites = analyticsData!['favorites_added'] ?? 0;
    final shares = analyticsData!['shares'] ?? 0;
    final promotionViews = analyticsData!['promotion_views'] ?? 0;
    
    if (totalViews == 0) return '0.0';
    
    // Weighted engagement score
    final favoriteWeight = favorites * 3;
    final shareWeight = shares * 5;
    final promotionWeight = promotionViews * 1;
    
    final engagementScore = ((favoriteWeight + shareWeight + promotionWeight) / totalViews * 10).clamp(0.0, 100.0);
    return engagementScore.toStringAsFixed(1);
  }

  String _formatUserType(String userType) {
    switch (userType.toLowerCase()) {
      case 'military':
        return 'Personal Militar';
      case 'police':
        return 'Policía';
      case 'government':
        return 'Gobierno';
      case 'beneficiary':
        return 'Beneficiarios';
      default:
        return userType.replaceFirst(userType[0], userType[0].toUpperCase());
    }
  }

  /// Safely casts dynamic map data to Map<String, dynamic>
  Map<String, dynamic> _safeMapCast(dynamic data) {
    if (data == null) return <String, dynamic>{};
    
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map<dynamic, dynamic>) {
      return data.cast<String, dynamic>();
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    
    return <String, dynamic>{};
  }
}
