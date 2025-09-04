//
//  ViewController.swift
//  BitcoinTrackerTutorial
//
//  Created by BERKAY TURAN on 1.09.2025.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var btcPrice: UILabel!
    @IBOutlet weak var ethPrice: UILabel!
    @IBOutlet weak var trPrice: UILabel!
    @IBOutlet weak var usdPrice: UILabel!
    @IBOutlet weak var euPrice: UILabel!
    @IBOutlet weak var lastUpdatedPrice: UILabel!
    
    let urlString = "https://api.coingecko.com/api/v3/exchange_rates"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        
        
        let timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(refreshData), userInfo: nil, repeats: true)
    }
    
    @objc func refreshData() -> Void {
        fetchData()
    }
    
    func fetchData() {
        guard let url = URL(string: urlString) else { return }
        let defaultSession = URLSession(configuration: .default)
        
        let dataTask = defaultSession.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
            
            if let error = error {
                print("Request error:", error)
                return
            }
            
            guard let data = data else {
                print("No data received.")
                return
            }
            
            do {
                let json = try JSONDecoder().decode(Rates.self, from: data)
                self.setPrices(currency : json.rates)
            }
            catch {
                print("Decoding error:", error)
                print("---- RAW JSON ----")
                print(String(data: data, encoding: .utf8) ?? "Invalid data")
                print("------------------")
                return
            }
        }
        dataTask.resume()
    }
    
    func setPrices(currency : Currency) {
        DispatchQueue.main.async {
            self.btcPrice.text = self.formatPrice(currency.btc)
            self.ethPrice.text = self.formatPrice(currency.eth)
            self.trPrice.text = self.formatPrice(currency.tr)
            self.usdPrice.text = self.formatPrice(currency.usd)
            self.euPrice.text = self.formatPrice(currency.eu)
            self.lastUpdatedPrice.text = self.formatDate(Date())
        }
    }
    
    func formatPrice(_ price: Price) -> String {
        return String(format: "%@ %.4f", price.unit, price.value)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM y HH:mm:ss"
        return formatter.string(from: date)
    }
    
    struct Rates : Codable {
        let rates: Currency
    }

    struct Currency: Codable {
        let btc: Price
        let eth: Price
        let tr: Price
        let usd: Price
        let eu: Price

        enum CodingKeys: String, CodingKey {
            case btc
            case eth
            case tr = "try"
            case usd
            case eu = "eur"
        }
    }

    struct Price: Codable {
        let name: String
        let unit: String
        let value: Float
        let type: String
    }
}
