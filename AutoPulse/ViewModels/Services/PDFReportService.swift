import UIKit
import PDFKit

class PDFReportService {
    static let shared = PDFReportService()

    func generateVehicleReport(
        vehicle: Vehicle,
        fuelRecords: [FuelRecord],
        maintenanceRecords: [MaintenanceRecord]
    ) -> Data? {

        let pageWidth: CGFloat = 612
        let pageHeight: CGFloat = 792
        let margin: CGFloat = 50
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let data = renderer.pdfData { context in
            context.beginPage()
            var yPosition: CGFloat = margin

            // ── HEADER ──────────────────────────────────────────
            let headerBg = CGRect(x: 0, y: 0, width: pageWidth, height: 100)
            UIColor(red: 0.05, green: 0.08, blue: 0.15, alpha: 1).setFill()
            UIRectFill(headerBg)

            // Logo circle
            let circleRect = CGRect(x: margin, y: 20, width: 60, height: 60)
            UIColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1).setFill()
            UIBezierPath(ovalIn: circleRect).fill()

            // App name
            let titleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 28),
                .foregroundColor: UIColor.white
            ]
            "AutoPulse".draw(at: CGPoint(x: margin + 75, y: 28), withAttributes: titleAttr)

            let subtitleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12),
                .foregroundColor: UIColor(white: 0.7, alpha: 1)
            ]
            "Vehicle Health Report".draw(at: CGPoint(x: margin + 75, y: 62), withAttributes: subtitleAttr)

            // Date
            let dateStr = Date().formatted(date: .long, time: .omitted)
            let dateAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor(white: 0.6, alpha: 1)
            ]
            let dateWidth = (dateStr as NSString).size(withAttributes: dateAttr).width
            dateStr.draw(at: CGPoint(x: pageWidth - margin - dateWidth, y: 45), withAttributes: dateAttr)

            yPosition = 120

            // ── VEHICLE INFO ─────────────────────────────────────
            yPosition = drawSectionTitle("Vehicle Information", at: yPosition, in: pageRect, margin: margin)

            let vehicleName = vehicle.nickname.isEmpty ? "\(vehicle.year) \(vehicle.make) \(vehicle.model)" : vehicle.nickname
            yPosition = drawInfoRow("Vehicle", value: vehicleName, at: yPosition, margin: margin, pageWidth: pageWidth)
            yPosition = drawInfoRow("Make", value: vehicle.make, at: yPosition, margin: margin, pageWidth: pageWidth)
            yPosition = drawInfoRow("Model", value: vehicle.model, at: yPosition, margin: margin, pageWidth: pageWidth)
            yPosition = drawInfoRow("Year", value: String(vehicle.year), at: yPosition, margin: margin, pageWidth: pageWidth)
            yPosition = drawInfoRow("Color", value: vehicle.color.isEmpty ? "—" : vehicle.color, at: yPosition, margin: margin, pageWidth: pageWidth)
            yPosition = drawInfoRow("Mileage", value: "\(vehicle.mileage) km", at: yPosition, margin: margin, pageWidth: pageWidth)
            if !vehicle.vin.isEmpty {
                yPosition = drawInfoRow("VIN", value: vehicle.vin, at: yPosition, margin: margin, pageWidth: pageWidth)
            }

            yPosition += 10

            // ── FUEL SUMMARY ─────────────────────────────────────
            yPosition = drawSectionTitle("Fuel Summary", at: yPosition, in: pageRect, margin: margin)

            let totalSpent = fuelRecords.reduce(0) { $0 + $1.totalCost }
            let totalLiters = fuelRecords.reduce(0) { $0 + $1.liters }
            let avgCost = fuelRecords.isEmpty ? 0 : totalSpent / totalLiters

            yPosition = drawInfoRow("Total Records", value: "\(fuelRecords.count)", at: yPosition, margin: margin, pageWidth: pageWidth)
            yPosition = drawInfoRow("Total Spent", value: String(format: "$%.2f", totalSpent), at: yPosition, margin: margin, pageWidth: pageWidth)
            yPosition = drawInfoRow("Total Liters", value: String(format: "%.1f L", totalLiters), at: yPosition, margin: margin, pageWidth: pageWidth)
            yPosition = drawInfoRow("Avg Cost/Liter", value: String(format: "$%.3f", avgCost), at: yPosition, margin: margin, pageWidth: pageWidth)

            yPosition += 10

            // ── MAINTENANCE SUMMARY ───────────────────────────────
            yPosition = drawSectionTitle("Maintenance Summary", at: yPosition, in: pageRect, margin: margin)

            let totalMaintenanceCost = maintenanceRecords.reduce(0) { $0 + $1.cost }
            yPosition = drawInfoRow("Total Services", value: "\(maintenanceRecords.count)", at: yPosition, margin: margin, pageWidth: pageWidth)
            yPosition = drawInfoRow("Total Spent", value: String(format: "$%.2f", totalMaintenanceCost), at: yPosition, margin: margin, pageWidth: pageWidth)

            if let last = maintenanceRecords.first {
                yPosition = drawInfoRow("Last Service", value: "\(last.serviceType) — \(last.date.formatted(date: .abbreviated, time: .omitted))", at: yPosition, margin: margin, pageWidth: pageWidth)
            }

            yPosition += 10

            // ── FUEL RECORDS ──────────────────────────────────────
            if !fuelRecords.isEmpty {
                yPosition = drawSectionTitle("Fuel Records", at: yPosition, in: pageRect, margin: margin)

                // Table header
                yPosition = drawTableHeader(["Date", "Liters", "$/L", "Total"], at: yPosition, margin: margin, pageWidth: pageWidth)

                for record in fuelRecords.prefix(15) {
                    if yPosition > pageHeight - 100 {
                        context.beginPage()
                        yPosition = margin
                    }
                    yPosition = drawTableRow([
                        record.date.formatted(date: .abbreviated, time: .omitted),
                        String(format: "%.1f L", record.liters),
                        String(format: "$%.3f", record.costPerLiter),
                        String(format: "$%.2f", record.totalCost)
                    ], at: yPosition, margin: margin, pageWidth: pageWidth)
                }

                yPosition += 10
            }

            // ── MAINTENANCE RECORDS ───────────────────────────────
            if !maintenanceRecords.isEmpty {
                if yPosition > pageHeight - 150 {
                    context.beginPage()
                    yPosition = margin
                }

                yPosition = drawSectionTitle("Service History", at: yPosition, in: pageRect, margin: margin)

                yPosition = drawTableHeader(["Date", "Service", "Mileage", "Cost"], at: yPosition, margin: margin, pageWidth: pageWidth)

                for record in maintenanceRecords.prefix(15) {
                    if yPosition > pageHeight - 100 {
                        context.beginPage()
                        yPosition = margin
                    }
                    yPosition = drawTableRow([
                        record.date.formatted(date: .abbreviated, time: .omitted),
                        record.serviceType,
                        "\(record.mileage) km",
                        String(format: "$%.2f", record.cost)
                    ], at: yPosition, margin: margin, pageWidth: pageWidth)
                }
            }

            // ── FOOTER ────────────────────────────────────────────
            let footerAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9),
                .foregroundColor: UIColor(white: 0.5, alpha: 1)
            ]
            let footer = "Generated by AutoPulse — jeancarlodev.com"
            let footerWidth = (footer as NSString).size(withAttributes: footerAttr).width
            footer.draw(at: CGPoint(x: (pageWidth - footerWidth) / 2, y: pageHeight - 30), withAttributes: footerAttr)
        }

        return data
    }

    // MARK: - Drawing Helpers

    private func drawSectionTitle(_ title: String, at y: CGFloat, in rect: CGRect, margin: CGFloat) -> CGFloat {
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 14),
            .foregroundColor: UIColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1)
        ]
        title.draw(at: CGPoint(x: margin, y: y), withAttributes: attr)

        let line = UIBezierPath()
        line.move(to: CGPoint(x: margin, y: y + 20))
        line.addLine(to: CGPoint(x: rect.width - margin, y: y + 20))
        UIColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 0.3).setStroke()
        line.lineWidth = 0.5
        line.stroke()

        return y + 30
    }

    private func drawInfoRow(_ label: String, value: String, at y: CGFloat, margin: CGFloat, pageWidth: CGFloat) -> CGFloat {
        let labelAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor(white: 0.5, alpha: 1)
        ]
        let valueAttr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 11),
            .foregroundColor: UIColor.black
        ]

        label.draw(at: CGPoint(x: margin, y: y), withAttributes: labelAttr)
        value.draw(at: CGPoint(x: margin + 150, y: y), withAttributes: valueAttr)

        return y + 18
    }

    private func drawTableHeader(_ columns: [String], at y: CGFloat, margin: CGFloat, pageWidth: CGFloat) -> CGFloat {
        let bgRect = CGRect(x: margin, y: y, width: pageWidth - margin * 2, height: 20)
        UIColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 0.15).setFill()
        UIRectFill(bgRect)

        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1)
        ]

        let colWidth = (pageWidth - margin * 2) / CGFloat(columns.count)
        for (i, col) in columns.enumerated() {
            col.draw(at: CGPoint(x: margin + CGFloat(i) * colWidth + 5, y: y + 5), withAttributes: attr)
        }

        return y + 22
    }

    private func drawTableRow(_ values: [String], at y: CGFloat, margin: CGFloat, pageWidth: CGFloat) -> CGFloat {
        let attr: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.black
        ]

        let colWidth = (pageWidth - margin * 2) / CGFloat(values.count)
        for (i, value) in values.enumerated() {
            value.draw(at: CGPoint(x: margin + CGFloat(i) * colWidth + 5, y: y + 3), withAttributes: attr)
        }

        let line = UIBezierPath()
        line.move(to: CGPoint(x: margin, y: y + 18))
        line.addLine(to: CGPoint(x: pageWidth - margin, y: y + 18))
        UIColor(white: 0.9, alpha: 1).setStroke()
        line.lineWidth = 0.3
        line.stroke()

        return y + 20
    }
}
