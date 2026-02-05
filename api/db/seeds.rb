# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admin user
admin_email = ENV.fetch("ADMIN_EMAIL", "admin@influenza.local")
admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")

User.find_or_create_by!(email_address: admin_email) do |user|
  user.password = admin_password
  user.admin = true
  puts "Created admin user: #{admin_email}"
end

# === Phase 3: Seed supported assets ===

puts "Seeding supported assets..."

# Crypto assets
[
  { symbol: "BTC", name: "Bitcoin", asset_class: "crypto", coingecko_id: "bitcoin" },
  { symbol: "ETH", name: "Ethereum", asset_class: "crypto", coingecko_id: "ethereum" },
  { symbol: "SOL", name: "Solana", asset_class: "crypto", coingecko_id: "solana" },
  { symbol: "XRP", name: "XRP", asset_class: "crypto", coingecko_id: "ripple" },
  { symbol: "ADA", name: "Cardano", asset_class: "crypto", coingecko_id: "cardano" },
  { symbol: "DOT", name: "Polkadot", asset_class: "crypto", coingecko_id: "polkadot" },
  { symbol: "AVAX", name: "Avalanche", asset_class: "crypto", coingecko_id: "avalanche-2" },
  { symbol: "LINK", name: "Chainlink", asset_class: "crypto", coingecko_id: "chainlink" },
  { symbol: "MATIC", name: "Polygon", asset_class: "crypto", coingecko_id: "matic-network" },
  { symbol: "DOGE", name: "Dogecoin", asset_class: "crypto", coingecko_id: "dogecoin" },
  { symbol: "SHIB", name: "Shiba Inu", asset_class: "crypto", coingecko_id: "shiba-inu" }
].each do |attrs|
  Asset.find_or_create_by!(symbol: attrs[:symbol]) do |asset|
    asset.name = attrs[:name]
    asset.asset_class = attrs[:asset_class]
    asset.coingecko_id = attrs[:coingecko_id]
  end
end

# Macro assets
[
  { symbol: "NASDAQ", name: "NASDAQ Composite", asset_class: "macro", yahoo_ticker: "^IXIC" },
  { symbol: "SP500", name: "S&P 500", asset_class: "macro", yahoo_ticker: "^GSPC" },
  { symbol: "DXY", name: "US Dollar Index", asset_class: "macro", yahoo_ticker: "DX-Y.NYB" },
  { symbol: "GOLD", name: "Gold", asset_class: "macro", yahoo_ticker: "GC=F" }
].each do |attrs|
  Asset.find_or_create_by!(symbol: attrs[:symbol]) do |asset|
    asset.name = attrs[:name]
    asset.asset_class = attrs[:asset_class]
    asset.yahoo_ticker = attrs[:yahoo_ticker]
  end
end

puts "Seeded #{Asset.count} assets (#{Asset.crypto.count} crypto, #{Asset.macro.count} macro)"
