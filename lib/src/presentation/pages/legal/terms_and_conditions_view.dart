import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class TermsAndConditionsView extends StatelessWidget {
  const TermsAndConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Términos y Condiciones'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Términos y Condiciones de Uso',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Última actualización: Enero 15, 2026',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              theme,
              '1. Aceptación de los Términos',
              'Al descargar, instalar o utilizar la aplicación móvil Heroes Colombia, '
              'usted acepta estar sujeto a estos Términos y Condiciones. Si no está de '
              'acuerdo con alguno de estos términos, no utilice esta aplicación.',
            ),

            _buildSection(
              theme,
              '2. Descripción del Servicio',
              'Heroes Colombia es una plataforma digital que conecta a personal militar, '
              'policía, bomberos y empleados del gobierno de Colombia con negocios locales '
              'que ofrecen descuentos y promociones especiales. El servicio permite:',
            ),
            _buildBulletList(theme, [
              'Buscar negocios y promociones cercanas',
              'Ver detalles de establecimientos participantes',
              'Guardar negocios y promociones favoritas',
              'Recibir notificaciones sobre nuevas ofertas',
            ]),

            _buildSection(
              theme,
              '3. Elegibilidad',
              'Esta aplicación está diseñada exclusivamente para:',
            ),
            _buildBulletList(theme, [
              'Personal militar activo y retirado de Colombia',
              'Miembros de la Policía Nacional',
              'Bomberos',
              'Empleados del gobierno colombiano',
              'Familiares directos de las personas mencionadas',
            ]),
            const SizedBox(height: 8),
            _buildText(
              theme,
              'Se requiere verificación de identidad mediante cédula militar o documento '
              'oficial. Heroes Colombia se reserva el derecho de solicitar documentación '
              'adicional para confirmar su elegibilidad.',
            ),

            _buildSection(
              theme,
              '4. Cuenta de Usuario',
              'Para utilizar Heroes Colombia, debe:',
            ),
            _buildBulletList(theme, [
              'Proporcionar información precisa y actualizada',
              'Mantener la seguridad de su contraseña',
              'Notificar inmediatamente cualquier uso no autorizado',
              'No compartir su cuenta con terceros',
              'No crear múltiples cuentas',
            ]),
            const SizedBox(height: 8),
            _buildText(
              theme,
              'Heroes Colombia se reserva el derecho de suspender o eliminar cuentas que '
              'violen estos términos o proporcionen información falsa.',
            ),

            _buildSection(
              theme,
              '5. Uso de Datos y Analíticas',
              'Al utilizar Heroes Colombia, usted acepta que recopilemos y procesemos datos '
              'de uso anónimos para mejorar la plataforma y proporcionar métricas a los negocios. '
              'Esto incluye:',
            ),
            _buildBulletList(theme, [
              'Páginas que visualiza y funciones que utiliza',
              'Negocios y promociones con los que interactúa',
              'Su ubicación aproximada (nivel de ciudad)',
              'Información del dispositivo (iOS/Android)',
            ]),
            const SizedBox(height: 8),
            _buildText(
              theme,
              'NO recopilamos: su ubicación GPS precisa sin permiso, conversaciones privadas, '
              'información de pago, o datos militares sensibles más allá de su rango.',
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 8),
            _buildText(
              theme,
              'Los datos agregados y anónimos se comparten con negocios para mostrar '
              'métricas de compromiso (impresiones, vistas, guardados). Su información '
              'personal NUNCA se comparte sin su consentimiento explícito.',
            ),

            _buildSection(
              theme,
              '6. Promociones y Descuentos',
              'Heroes Colombia actúa como plataforma de conexión entre usuarios y negocios:',
            ),
            _buildBulletList(theme, [
              'No garantizamos la disponibilidad continua de promociones',
              'Los negocios son responsables de honrar sus ofertas',
              'Las condiciones de cada promoción las establece el negocio',
              'Heroes Colombia no es responsable de disputas entre usuarios y negocios',
            ]),

            _buildSection(
              theme,
              '7. Contenido Generado por Usuarios',
              'Si Heroes Colombia habilita reseñas o comentarios en el futuro:',
            ),
            _buildBulletList(theme, [
              'Usted es responsable del contenido que publica',
              'No debe publicar contenido ofensivo, difamatorio o ilegal',
              'Heroes Colombia se reserva el derecho de eliminar contenido inapropiado',
              'Usted otorga a Heroes Colombia licencia para usar su contenido público',
            ]),

            _buildSection(
              theme,
              '8. Propiedad Intelectual',
              'Todos los derechos de propiedad intelectual de la aplicación Heroes Colombia, '
              'incluyendo diseño, código, marcas y contenido, pertenecen a Heroes Colombia. '
              'No está permitido:',
            ),
            _buildBulletList(theme, [
              'Copiar o reproducir la aplicación',
              'Realizar ingeniería inversa del código',
              'Usar el nombre o logo de Heroes Colombia sin autorización',
              'Redistribuir o revender el acceso a la plataforma',
            ]),

            _buildSection(
              theme,
              '9. Limitación de Responsabilidad',
              'Heroes Colombia se proporciona "tal cual" sin garantías de ningún tipo. '
              'No somos responsables por:',
            ),
            _buildBulletList(theme, [
              'Daños o pérdidas derivadas del uso de la aplicación',
              'Interrupciones del servicio o errores técnicos',
              'Acciones de terceros (negocios participantes)',
              'Pérdida de datos o información',
            ]),

            _buildSection(
              theme,
              '10. Modificaciones al Servicio',
              'Heroes Colombia se reserva el derecho de:',
            ),
            _buildBulletList(theme, [
              'Modificar o descontinuar cualquier función',
              'Actualizar estos términos en cualquier momento',
              'Cambiar requisitos de elegibilidad',
              'Modificar las políticas de privacidad',
            ]),
            const SizedBox(height: 8),
            _buildText(
              theme,
              'Las modificaciones importantes se notificarán a través de la aplicación. '
              'El uso continuo después de cambios constituye aceptación.',
            ),

            _buildSection(
              theme,
              '11. Cancelación de Cuenta',
              'Usted puede cancelar su cuenta en cualquier momento desde la configuración. '
              'Al cancelar:',
            ),
            _buildBulletList(theme, [
              'Sus datos personales se eliminarán dentro de 30 días',
              'Los datos analíticos anónimos se mantienen para métricas agregadas',
              'No se pueden recuperar promociones guardadas',
              'El acceso a la aplicación se revoca inmediatamente',
            ]),

            _buildSection(
              theme,
              '12. Jurisdicción y Ley Aplicable',
              'Estos términos se rigen por las leyes de la República de Colombia. '
              'Cualquier disputa se resolverá en los tribunales competentes de Bogotá, Colombia.',
            ),

            _buildSection(
              theme,
              '13. Contacto',
              'Para preguntas sobre estos términos, contáctenos en:',
            ),
            _buildBulletList(theme, [
              'Email de soporte: soporte@heroescolombia.com',
            ]),

            const SizedBox(height: 32),
            Text(
              '---',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Al hacer clic en "Acepto" o continuar usando Heroes Colombia, '
              'usted confirma que ha leído, comprendido y acepta estos Términos y Condiciones.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _buildText(
    ThemeData theme,
    String content, {
    FontWeight? fontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        content,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: fontWeight,
        ),
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _buildBulletList(ThemeData theme, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
