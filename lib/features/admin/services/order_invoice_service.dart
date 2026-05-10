import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/utils/delivery_type.dart';
import '../model/OrdersAgentModel.dart';

class OrderInvoiceService {
  const OrderInvoiceService();

  Future<void> shareInvoice(Order order) async {
    final bytes = await _buildInvoice(order);
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'invoice-order-${order.id}.pdf',
    );
  }

  Future<Uint8List> _buildInvoice(Order order) async {
    final regularFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo/static/Cairo-Regular.ttf'),
    );
    final boldFont = pw.Font.ttf(
      await rootBundle.load('assets/fonts/Cairo/static/Cairo-Bold.ttf'),
    );
    final dateFormat = DateFormat('yyyy/MM/dd - hh:mm a');
    final moneyFormat = NumberFormat('#,###');
    final document = pw.Document();

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          textDirection: pw.TextDirection.rtl,
          theme: pw.ThemeData.withFont(base: regularFont, bold: boldFont),
        ),
        build:
            (context) => [
              _header(order, dateFormat),
              pw.SizedBox(height: 18),
              _sectionTitle('بيانات الطلب'),
              pw.SizedBox(height: 8),
              _infoGrid([
                _InfoItem('رقم الطلب', '#${order.id}'),
                _InfoItem('تاريخ الطلب', dateFormat.format(order.createdAt)),
                _InfoItem('رقم الحساب', order.phone),
                if (order.secondaryPhone.isNotEmpty)
                  _InfoItem('رقم إضافي', order.secondaryPhone),
                _InfoItem('نوع التوصيل', deliveryTypeLabel(order.deliveryType)),
                _InfoItem('العنوان', order.address),
                _InfoItem('حالة الطلب', order.status),
              ]),
              pw.SizedBox(height: 18),
              _sectionTitle('المنتجات'),
              pw.SizedBox(height: 8),
              _itemsTable(order, moneyFormat),
              pw.SizedBox(height: 16),
              _totals(order, moneyFormat),
              pw.Spacer(),
              _footer(),
            ],
      ),
    );

    return document.save();
  }

  pw.Widget _header(Order order, DateFormat dateFormat) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#1A1A2E'),
        borderRadius: pw.BorderRadius.circular(12),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'فاتورة طلب',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'تم الإنشاء: ${dateFormat.format(DateTime.now())}',
                style: const pw.TextStyle(color: PdfColors.white, fontSize: 10),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('#F9B51E'),
              borderRadius: pw.BorderRadius.circular(18),
            ),
            child: pw.Text(
              '#${order.id}',
              style: pw.TextStyle(
                color: PdfColor.fromHex('#1A1A2E'),
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _sectionTitle(String title) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        title,
        style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  pw.Widget _infoGrid(List<_InfoItem> items) {
    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          items.map((item) {
            return pw.Container(
              width: 255,
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColor.fromHex('#F0EBE3')),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    item.label,
                    style: const pw.TextStyle(
                      color: PdfColors.grey700,
                      fontSize: 9,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    item.value.isEmpty ? '-' : item.value,
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  pw.Widget _itemsTable(Order order, NumberFormat moneyFormat) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColor.fromHex('#F0EBE3')),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.1),
        1: pw.FlexColumnWidth(1),
        2: pw.FlexColumnWidth(1),
        3: pw.FlexColumnWidth(3),
        4: pw.FlexColumnWidth(0.7),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColor.fromHex('#FDF8F2')),
          children: [
            _cell('المجموع', bold: true),
            _cell('السعر', bold: true),
            _cell('العدد', bold: true),
            _cell('المنتج', bold: true),
            _cell('#', bold: true),
          ],
        ),
        ...order.items.asMap().entries.map((entry) {
          final index = entry.key + 1;
          final item = entry.value;
          final lineTotal = item.quantity * item.priceAtOrder;
          return pw.TableRow(
            children: [
              _cell('${moneyFormat.format(lineTotal)} د.ع'),
              _cell('${moneyFormat.format(item.priceAtOrder)} د.ع'),
              _cell(item.quantity.toString()),
              _cell('${item.productAgent.title}\nID: ${item.productAgent.id}'),
              _cell(index.toString()),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _cell(String text, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  pw.Widget _totals(Order order, NumberFormat moneyFormat) {
    return pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Container(
        width: 220,
        padding: const pw.EdgeInsets.all(14),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#1A1A2E'),
          borderRadius: pw.BorderRadius.circular(12),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            _totalLine('عدد القطع', order.totalItems.toString()),
            pw.Divider(color: PdfColors.white),
            _totalLine(
              'المجموع الكلي',
              '${moneyFormat.format(order.totalPrice)} د.ع',
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _totalLine(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          label,
          style: const pw.TextStyle(color: PdfColors.white, fontSize: 11),
        ),
      ],
    );
  }

  pw.Widget _footer() {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.only(top: 12),
      child: pw.Text(
        'شكراً لتعاملكم معنا',
        style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
      ),
    );
  }
}

class _InfoItem {
  const _InfoItem(this.label, this.value);

  final String label;
  final String value;
}
