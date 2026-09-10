import Foundation
import CoreLocation
import Combine

class WeatherService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var weatherAlert: String = ""
    @Published var locationGranted = false
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocationAndFetch() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationGranted = true
            locationManager.requestLocation()
        default:
            locationGranted = false
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        fetchWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    func fetchWeather(lat: Double, lon: Double) {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(lat)&longitude=\(lon)&current=temperature_2m,weathercode&temperature_unit=celsius"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let current = json["current"] as? [String: Any],
               let temp = current["temperature_2m"] as? Double,
               let code = current["weathercode"] as? Int {
                
                let alert = self.buildAlert(temp: temp, code: code)
                
                DispatchQueue.main.async {
                    self.weatherAlert = alert
                }
            }
        }.resume()
    }
    
    func buildAlert(temp: Double, code: Int) -> String {
        let tempStr = String(format: "%.0f°C", temp)
        let tip: String
        
        switch code {
        case 0, 1:
            if temp > 30 {
                tip = String(localized: "Check your coolant level and tire pressure.")
            } else if temp < 0 {
                tip = String(localized: "Check your battery and antifreeze levels.")
            } else {
                tip = String(localized: "Great driving conditions today!")
            }
        case 2, 3:
            tip = String(localized: "Cloudy today. Check your headlights are working.")
        case 51, 53, 55, 61, 63, 65:
            tip = String(localized: "Rain expected. Check your windshield washer fluid.")
        case 71, 73, 75, 77:
            tip = String(localized: "Snow expected. Check your winter tires and wipers.")
        case 80, 81, 82:
            tip = String(localized: "Rain showers today. Keep your wipers in good condition.")
        case 95, 96, 99:
            tip = String(localized: "Thunderstorm expected. Avoid driving if possible.")
        default:
            tip = String(localized: "Check your vehicle before heading out.")
        }
        
        let emoji: String
        switch code {
        case 0, 1: emoji = temp > 30 ? "☀️" : temp < 0 ? "🥶" : "☀️"
        case 2, 3: emoji = "⛅"
        case 51, 53, 55, 61, 63, 65: emoji = "🌧️"
        case 71, 73, 75, 77: emoji = "❄️"
        case 80, 81, 82: emoji = "🌦️"
        case 95, 96, 99: emoji = "⛈️"
        default: emoji = "🌡️"
        }
        
        return "\(emoji) \(tempStr) — \(tip)"
    }
}
