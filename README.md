# Oguzhan-Tunc---Case

Uygulama Qt 6.8.3 versiyonu ile geliştirilmiştir.

# Gereksinim 1:

Uygulama Qt&Qml ile responsive olacak şekilde geliştirilmiştir.


# Gereksinim 2:

2.1)Proje dizininde bulunan, "/build/Desktop_Qt_6_9_0-Debug/scene.xml" dosyası ile dinamik olarak görsel oluşturulabilmektedir.

2.2)XML dosyasında syntax hatası yapılırsa, uygulamada bir hatanın açıklaması yazan bir QDialog belirmektedir. Ayrıca her hata "/build/Desktop_Qt_6_9_0-Debug/xmlLog.log" log dosyasında örnek olarak;
[2025-04-28 01:53:32] XML parse error: Expected '>' or '/', but got '[a-zA-Z]'.
şeklinde kayıt edilmektedir.

Proje içerisinde halihazırda bulunan sample.png dışında farklı bir "Image" shape'inin kullanılması için qrc ve CMakeList.txt dosyalarına dahil edilmesi gerekmektedir.

2.3)Hata mesajı kapatıldığında uygulama çalışmaya devam etmektedir.


# Gereksinim 3:

Uygulamanın alt yarısında sistemde çalışan UDP soketleri listelenmektedir. Çıktı 2 saniyede bir güncellenmekle beraber, "Update UDP Socket List" butonu ile de güncellenebilmektedir. 


# Gereksinim 4:

4.1) Bağlanılacak olan UDP Multicast adresi hem "UDP Socket List" listview'ından seçilerek hem de manuel olarak elle girilerek ayarlanabilmektedir. 

4.2) UDP Multicast adresi 4.1'de belirtilen seçeneklerden biriyle girildikten sonra Listen butonuna basıldığında gönderilen datagramlar arayüzde görüntülenmektedir. Bunun testi için "/TestFiles/udpPublisher.c" programı derleyip çalıştırmaya hazırdır. Çalıştırıldığında, "UDP Socket List"in güncellendiği görülmektedir. 

4.3)UDP verileri alınıp listeye yazılırken uygulamada herhangi bir donma gözlemlenmemektedir.

4.4) Bir multicast adresiyle bağlantı kurulurken herhangi bir hata alınırsa bu hata arayüzde QDialog ile gösterilmekle birlikte, "/build/Desktop_Qt_6_9_0-Debug/udp_listener_log.log" dosyasında log'u tutulmaktadır. Örnek log kaydı aşağıda verilmiştir.
2025-04-28 03:04:23 [ERROR]: UDP bind failed: The bound address is already in use


# Gereksinim 5:

5.1) Uygulama hem listener hem publisher olarak çalışabilmektedir. Bunun testi için izlenmesi gereken adımlar şunlardır: 
-Arayüzün sol altında bulunan "Enter the message to send..." kısmına gönderilmek istenen mesaj içeriği girilir.
-Publish edilecek adres ve port değerleri ilgili yerlere girilir.
-Publish butonuna basılır.
-Publish edilen adres ve port "UDP Socket List" yenilendiğinde görünecektir. Bu adres ve port değerleri, listener kısmında bulunan adres ve port'a girilerek "Listen" butonuna basıldığında, uygulamanın gönderdiği mesajların UDP mesajlarının alındığı listView'a geldiği görülmektedir.

5.2)Uygulamanın herhangi bir anda Listening ve Publishing yaptığının anlaşılmasını sağlayacak olan indikatör görevi butonlara verilmiştir. Butonların renk ve text ögelerine göre bunun hakkında bilgi sahibi olunabilmektedir.


# Gereksinim 6:

6.1) Uygulama socketCAN okuyabilmektedir. Terminal üzerinden sırasıyla "sudo ip link add dev vcan1 type vcan" ve "sudo ip link set up vcan1" girildiğinde sanal CAN arayüzü, kullanıcı arayüzünde bulunan "socketCAN Interfaces" isimli listView'a gelmektedir. 

6.2)"socketCAN Interfaces" isimli, sistemde bulunan CAN arayüzlerini görün
tüleyen listView, 5 saniyede bir güncellenmekle birlikte hemen altında bulunan "Update List" butonu ile de güncellenebilmektedir. 

6.3) Eğer ki sistemde fiziksel bir CAN arayüzü varsa listede görünecek ve buradan seçilebilecektir. Seçildiği takdirde baudrate girişi aktif hale gelecektir. Tarafımca fiziksel bir CAN arayüzü görüntülemek mümkün olmayacağı için bu kısmın doğrulaması kodda yapılan ufak bir değişiklikle test edilmiştir.

6.4) Uygulamaya gelen socketCAN mesajları iki farklı yere yönlendirilebilmektedir. Bunlar için kullanım senaryoları aşağıda oluşturulmuştur.

# Senaryo 1 - Gelen mesajları ListView'a basmak: 
- vcan0, sanal Can arayüzü işletim sisteminde oluşturulup "UP"a çekilir.
- "/TestFiles/socketCan.c" dosyası derlenip çalıştırıldığında vcan0 üzerinden socketCAN mesajlarını yollar.
- "socketCAN Interfaces" listView'ından vcan0 seçilir.
- Message Mode QComboBox'ı yardımıyla LIST mod seçilir.
- Listen butonuna basılır.
- socketCAN ile yollanan datalar Listen butonunun hemen altında bulunan listView içine akmaya başlar.

# Senaryo 2 - Gelen mesajları UDP ile multicast olarak yayınlamak:
- vcan0, sanal Can arayüzü işletim sisteminde oluşturulup "UP"a çekilir.
- "/TestFiles/socketCan.c" dosyası derlenip çalıştırıldığında vcan0 üzerinden socketCAN mesajlarını yollar.
- "socketCAN Interfaces" listView'ından vcan0 seçilir.
- "Message Mode QComboBox"ı yardımıyla UDP mod seçilir. (Bu işlem yapıldığında UDP ile yollanacak mesajların girilmesine yarayan TextBox inaktif hale gelir.)
- İstenen adres ve port değerleri UDP Publish'te ilgili yerlere girilir. ve Listen butonuna basılır. 
- Listen butonuna basıldığında uygulama otomatik olarak gelen mesajları girilen adres ve port üzerinden multicast yapmaya başlar.
- UDP üzerinden yollanan socketCAN verileri, güncellenen "UDP Socket List" üzerinden seçilip dinlemeye başlanabilir.
- Mesajlar arayüze gelen UDP verilerinin yazıldığı ListView'a basılmaya başlanır.

Not: Uygulamada kayıt edilecek bir konfigürasyon bulunamadığı için konfigürasyon dosyası oluşturulamamıştır.
 

# OguzhanTunc-Case

# OguzhanTunc-Case
