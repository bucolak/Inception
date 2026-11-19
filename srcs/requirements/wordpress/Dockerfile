FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    # PHP-FPM servisi, PHP’yi çalıştıran motor. Asıl paket bu.
    php8.2-fpm \
    # PHP’nin MariaDB’ye bağlanmasını sağlar (mysqli). Connected! testinde kullandığımız buydu.
    php8.2-mysql \
    # WordPress’in internete istek atması için (güncellemeler, eklentiler).
    php8.2-curl \
    # Resim işleme (yüklenen resimlerin küçültülmesi gibi).
    php8.2-gd \
    # XML okuma (RSS, bazı eklentiler).
    php8.2-xml \
    # Çok baytlı karakterler, yani Türkçe karakterler gibi ASCII dışı metinler.
    php8.2-mbstring \
    # Eklenti ve tema yüklerken zip dosyalarını açmak için.
    php8.2-zip \
    # Dil ve bölge ayarları (tarih, sayı biçimleri).
    php8.2-intl \
    # Komut satırından dosya indirmek için program. WordPress’i ve WP-CLI’ı indirmekte kullanıyoruz.
    curl \
    # HTTPS sitelerinin sertifikalarını doğrulamak için güvenilir kök sertifikalar. Bu paket olmadan curl https://... “sertifika doğrulanamadı” hatası verir.
    ca-certificates \
    # mariadb-admin ping ile MariaDB’yi beklemek için.
    mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    # mkdir -p /var/www/html: WordPress dosyalarının konacağı dizin. -p dizin zaten varsa hata vermez.
    && mkdir -p /var/www/html \
    # curl -fsSL: dört seçenek bir arada:
       # -f: sunucu hata döndürürse (404 gibi) başarısız say, hata sayfasını dosya diye indirme
       # -s: ilerleme çubuğunu gösterme (silent)
       # -S: ama hata olursa mesajı göster
       # -L: yönlendirmeleri takip et
       # | (pipe): curl’ün indirdiği veriyi diske yazmadan doğrudan tar’a aktarır.
       # tar -xz: arşivi aç (x = extract), gzip ile sıkıştırılmış (z).
       # --strip-components=1: Arşivin içinde her şey bir wordpress/ klasörünün içinde. Bu seçenek o en üstteki klasörü atlar. Böylece dosyalar /var/www/html/wordpress/... yerine doğrudan /var/www/html/... altına açılır.
       # -C /var/www/html: dosyaları bu dizine aç.
    && curl -fsSL https://wordpress.org/latest.tar.gz \
    | tar -xz --strip-components=1 -C /var/www/html

RUN curl -fsSL -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp


# www.conf: PHP-FPM’in ayar dosyası. Varsayılan ayarda PHP-FPM bir Unix socket (/run/php/php8.2-fpm.sock) üzerinden dinliyor.
# Bu satır o ayarı listen = 9000 ile değiştiriyor, yani TCP 9000 portunda dinle.
# Neden? MariaDB’den hatırla: Unix socket sadece aynı container içinden kullanılabilir. NGINX ise başka bir container’da, ona network üzerinden, yani TCP ile ulaşması gerekiyor. MariaDB’deki bind-address değişikliğinin aynısı.
# sed -i 's|eski|yeni|': dosyada “eski” metni bul ve “yeni” ile değiştir. -i değişikliği dosyanın üzerine yazar. Ayırıcı olarak / yerine | kullandık, çünkü metnin içinde zaten / karakterleri var.
RUN sed -i 's|listen = /run/php/php8.2-fpm.sock|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf

# Container başlayınca PHP-FPM’i çalıştır.
# -F (foreground): PHP-FPM normalde başlayınca arka plana geçip kendi kendini daemon yapar. O zaman PID 1 olan süreç hemen biter ve container kapanır. -F “ön planda kal” demek, böylece PID 1 olarak kalır. MariaDB’de konuştuğumuz PID 1 kuralının aynısı.
CMD ["php-fpm8.2", "-F"]



# İlk RUN “paketleri kur ve WordPress’i indir” işini yapıyor.