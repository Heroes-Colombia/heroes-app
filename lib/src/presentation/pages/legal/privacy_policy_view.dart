import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class PrivacyPolicyView extends StatelessWidget {
  const PrivacyPolicyView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Política de Privacidad'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Política de Privacidad',
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
              '1. Introducción',
              'Heroes Colombia ("nosotros", "nuestro") se compromete a proteger la privacidad '
              'de los miembros de las fuerzas armadas, policía, bomberos y empleados del gobierno '
              'de Colombia que utilizan nuestra aplicación móvil. Esta política explica qué '
              'información recopilamos, cómo la usamos y sus derechos sobre sus datos personales.',
            ),

            _buildSection(
              theme,
              '2. Información que Recopilamos',
              '',
            ),

            _buildSubSection(
              theme,
              '2.1 Información de Registro',
              'Cuando crea una cuenta, recopilamos:',
            ),
            _buildBulletList(theme, [
              'Nombre completo',
              'Correo electrónico',
              'Número de cédula o cédula militar',
              'Rango o cargo (para verificación)',
              'Institución (Ejército, Policía, etc.)',
              'Ciudad de residencia (nivel de ciudad, no dirección exacta)',
            ]),

            _buildSubSection(
              theme,
              '2.2 Datos de Uso y Analíticas',
              'Para mejorar la experiencia del usuario y proporcionar métricas a los negocios, '
              'recopilamos datos de uso anónimos:',
            ),
            _buildBulletList(theme, [
              'Impresiones: Cuando un negocio o promoción aparece en su pantalla',
              'Vistas: Cuando abre la página de detalles de un negocio o promoción',
              'Guardados: Cuando marca un negocio o promoción como favorito',
              'Búsquedas: Términos de búsqueda y resultados (anónimos)',
              'Pantallas visitadas y duración de sesión',
              'Tipo de dispositivo (iOS o Android)',
              'Ubicación aproximada (nivel de ciudad)',
            ]),

            const SizedBox(height: 8),
            _buildText(
              theme,
              'Importante: Los datos analíticos se agregan y anonimizan antes de compartirse '
              'con negocios. Los negocios ven métricas totales (ej: "500 impresiones"), NO '
              'información individual identificable.',
              fontWeight: FontWeight.w600,
            ),

            _buildSubSection(
              theme,
              '2.3 Información de Ubicación',
              'Heroes Colombia utiliza datos de ubicación de las siguientes formas:',
            ),
            _buildBulletList(theme, [
              'Ubicación aproximada (ciudad): Recopilada automáticamente para mostrar negocios cercanos',
              'Ubicación precisa (GPS): SOLO si usted habilita permisos de ubicación para usar el mapa',
              'La ubicación GPS precisa NUNCA se almacena ni se comparte con terceros',
            ]),

            _buildSubSection(
              theme,
              '2.4 Datos que NO Recopilamos',
              'Heroes Colombia NO recopila:',
            ),
            _buildBulletList(theme, [
              'Información de pago o tarjetas de crédito',
              'Mensajes privados o conversaciones (la app no tiene chat)',
              'Contactos de su teléfono',
              'Fotos o archivos de su dispositivo',
              'Datos militares sensibles más allá del rango',
              'Historial de navegación fuera de la aplicación',
            ]),

            _buildSection(
              theme,
              '3. Cómo Usamos su Información',
              '',
            ),

            _buildSubSection(
              theme,
              '3.1 Servicios Principales',
              '',
            ),
            _buildBulletList(theme, [
              'Verificar su elegibilidad como beneficiario',
              'Personalizar recomendaciones de negocios',
              'Mostrar promociones relevantes en su área',
              'Permitir guardar favoritos y preferencias',
              'Enviar notificaciones sobre ofertas (si está habilitado)',
            ]),

            _buildSubSection(
              theme,
              '3.2 Analíticas para Negocios (Anónimas)',
              'Los datos de uso se agregan para proporcionar a los negocios métricas como:',
            ),
            _buildBulletList(theme, [
              'Número total de impresiones y vistas',
              'Tasa de conversión (vistas → guardados)',
              'Demografía general (ej: "40% son de Bogotá", "60% son militares")',
              'Tendencias de popularidad de promociones',
            ]),

            const SizedBox(height: 8),
            _buildText(
              theme,
              'Ejemplo de datos compartidos: "La promoción X tuvo 1,000 impresiones y 250 vistas '
              'esta semana, con 20% de conversión." Los negocios NO ven nombres, correos ni '
              'identificadores individuales.',
              fontStyle: FontStyle.italic,
            ),

            _buildSubSection(
              theme,
              '3.3 Mejoras del Producto',
              '',
            ),
            _buildBulletList(theme, [
              'Analizar patrones de uso para mejorar funciones',
              'Identificar y corregir errores técnicos',
              'Optimizar rendimiento de la aplicación',
              'Desarrollar nuevas características basadas en comportamiento del usuario',
            ]),

            _buildSection(
              theme,
              '4. Compartir Información con Terceros',
              '',
            ),

            _buildSubSection(
              theme,
              '4.1 Negocios Participantes',
              'Compartimos con negocios SOLO:',
            ),
            _buildBulletList(theme, [
              'Métricas agregadas y anónimas (impresiones, vistas, guardados)',
              'Demografía general (rangos, ciudades) en forma agregada',
              'NUNCA compartimos: nombres, correos, números de cédula, o identificadores personales',
            ]),

            _buildSubSection(
              theme,
              '4.2 Proveedores de Servicios',
              'Usamos proveedores externos para operar Heroes Colombia:',
            ),
            _buildBulletList(theme, [
              'Firebase (Google): Autenticación, base de datos, analíticas',
              'Google Maps: Servicios de mapas y ubicación',
              'Estos proveedores tienen acceso limitado solo para operar servicios',
            ]),

            _buildSubSection(
              theme,
              '4.3 Requisitos Legales',
              'Podemos divulgar información si es requerido por:',
            ),
            _buildBulletList(theme, [
              'Orden judicial o proceso legal',
              'Autoridades gubernamentales colombianas',
              'Proteger derechos y seguridad de Heroes Colombia o usuarios',
            ]),

            _buildSection(
              theme,
              '5. Seguridad de Datos',
              'Heroes Colombia implementa medidas de seguridad estándar de la industria:',
            ),
            _buildBulletList(theme, [
              'Cifrado de datos en tránsito (HTTPS/TLS)',
              'Cifrado de datos en reposo (Firebase Firestore)',
              'Autenticación segura con Firebase Auth',
              'Acceso restringido a datos personales (solo personal autorizado)',
              'Monitoreo de seguridad y auditorías regulares',
            ]),

            const SizedBox(height: 8),
            _buildText(
              theme,
              'Sin embargo, ningún sistema es 100% seguro. No podemos garantizar '
              'seguridad absoluta contra brechas de datos.',
              fontWeight: FontWeight.w600,
            ),

            _buildSection(
              theme,
              '6. Retención de Datos',
              '',
            ),
            _buildBulletList(theme, [
              'Datos de cuenta: Se mantienen mientras su cuenta esté activa',
              'Datos analíticos: Se retienen por 90 días (configurable)',
              'Datos agregados: Se pueden mantener indefinidamente para estadísticas generales',
              'Al eliminar su cuenta: Datos personales se borran en 30 días',
            ]),

            _buildSection(
              theme,
              '7. Sus Derechos (GDPR y Ley Colombiana)',
              'Como usuario, usted tiene derecho a:',
            ),
            _buildBulletList(theme, [
              'Acceso: Solicitar copia de sus datos personales',
              'Rectificación: Corregir información incorrecta',
              'Eliminación: Solicitar borrado de sus datos ("derecho al olvido")',
              'Portabilidad: Obtener sus datos en formato legible',
              'Oposición: Rechazar ciertos usos de sus datos',
              'Restricción: Limitar procesamiento de sus datos',
            ]),

            const SizedBox(height: 8),
            _buildText(
              theme,
              'Para ejercer estos derechos, contáctenos en: soporte@heroescolombia.com',
              fontWeight: FontWeight.w600,
            ),

            _buildSection(
              theme,
              '8. Cookies y Tecnologías de Seguimiento',
              'Heroes Colombia utiliza:',
            ),
            _buildBulletList(theme, [
              'Firebase Analytics: Rastreo de eventos en la aplicación (impresiones, vistas, etc.)',
              'Session IDs: Identificadores temporales para analizar flujos de usuario',
              'Tokens de autenticación: Para mantener sesión activa',
            ]),

            const SizedBox(height: 8),
            _buildText(
              theme,
              'No usamos cookies de terceros para publicidad. Todos los datos se usan '
              'exclusivamente para operar y mejorar Heroes Colombia.',
            ),

            _buildSection(
              theme,
              '9. Menores de Edad',
              'Heroes Colombia requiere que los usuarios tengan al menos 18 años. No '
              'recopilamos intencionalmente datos de menores. Si descubrimos que un menor '
              'creó una cuenta, la eliminaremos inmediatamente.',
            ),

            _buildSection(
              theme,
              '10. Cambios a esta Política',
              'Podemos actualizar esta política periódicamente. Los cambios importantes se '
              'notificarán mediante:',
            ),
            _buildBulletList(theme, [
              'Notificación en la aplicación',
              'Correo electrónico a usuarios registrados',
              'Actualización de la fecha "Última actualización"',
            ]),

            const SizedBox(height: 8),
            _buildText(
              theme,
              'El uso continuo de Heroes Colombia después de cambios constituye aceptación '
              'de la política actualizada.',
            ),

            _buildSection(
              theme,
              '11. Transferencias Internacionales de Datos',
              'Sus datos pueden procesarse en servidores ubicados fuera de Colombia (ej: Firebase '
              'utiliza centros de datos de Google en múltiples países). Nos aseguramos de que '
              'estos proveedores cumplan con estándares de protección de datos equivalentes a '
              'las leyes colombianas.',
            ),

            _buildSection(
              theme,
              '12. Contacto',
              'Para preguntas sobre privacidad o ejercer sus derechos:',
            ),
            _buildBulletList(theme, [
              'Email de soporte: soporte@heroescolombia.com',
              'Tiempo de respuesta: Dentro de 30 días hábiles',
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
              'Al usar Heroes Colombia, usted acepta esta Política de Privacidad y el '
              'procesamiento de sus datos según lo descrito aquí.',
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
          if (content.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              content,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubSection(ThemeData theme, String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (content.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              content,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.justify,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildText(
    ThemeData theme,
    String content, {
    FontWeight? fontWeight,
    FontStyle? fontStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        content,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: fontWeight,
          fontStyle: fontStyle,
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
