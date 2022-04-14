# R Studio - Twitter Text Mining and Sentiment Analysis

I MIGHT TRANSLATE README INTO ENGLISH IF THIS GETS ANY ATTENTION FROM NON-TURKISH SPEAKERS. JUST LET ME KNOW.

ÖNEMLİ NOT: TWITTER'DA METİN MADENCİLİĞİ VE DUYGU ANALİZİ YAPABİLMEK İÇİN TWITTER DEVELOPER HESABINA SAHİP OLMANIZ GEREKMEKTEDİR. TWITTER DEVELOPER HESABI BAŞVURUSU YAPMAK İÇİN İNTERNETTE BULUNAN REHBER VİDEOLARI VE YAZILARI İNCELEYEBİLİRSİNİZ.  


PROJENİN ÖZETİ

15 Aralık 2021 ve 17 Ocak 2022 tarihleri arasında Türkiye bölgesinde “Steam” hakkında atılan 7500 adet tweet toplanmış olup, bu tweet’ler veri temizleme aşamalarından geçirildikten sonra metin madenciliği ve duygu analizi işlemlerine tabi tutulmuştur. Metin madenciliği sayesinde belirtilen tarihler aralığında bulunan tweet’ler içerisinde “Steam” kelimesi ile birlikte en fazla kullanılan diğer kelimeler ortaya çıkmıştır. Duygu analizi aşamasında ise belirtilen bu tarihler aralığında atılan tweet’lerde bulunan pozitif ve negatif kelimeler tespit edilmiştir. Cümlelerde bulunan pozitif ve negatif kelimelerden hangisi fazlalıktaysa tweet’ler bu işleme göre pozitif veya negatif cümle olarak ayrılmıştır. Cümlelerde bulunan negatif ve pozitif kelimeler eşitse veya bunlardan her ikisi de cümlelerde bulunmuyorsa ise bu cümleler de nötr olarak gruplandırılmıştır. Bu sayede bu tarihler aralığında atılan tweet’lerden yola çıkarak 7500 adet tweet içerinden kaç tanesinin “Steam” hakkında pozitif, negatif veya nötr fikre sahip olduğuna ulaşılmıştır. Bu işlemlerin tamamı R programlama diliyle yapılmıştır.


METİN MADENCİLİĞİ ADIM ADIM

Metin Madenciliği için twitter_steam_text_mining.R adlı dosyaya gidiniz.

R kodlarının çalışması için öncelikle gerekli olan paketlerin bilgisayara yüklenmesi gerekiyor. Bunun için install.packages() komutunu kullanıyoruz.
Gerekli olan paketler bilgisayara yüklendikten sonra ise bu paketlerin kütüphaneden çağrılması gerekiyor. Bunun için ise library() komutunu kullanıyoruz.

Paketleri kütüphaneden çağırdıktan sonra ise bu projenin çalışması için gerekli olan ve Twitter tarafından verilen Twitter Developer hesabına ait olan bilgileri çağırıyoruz. Bu noktada "SSSSSSS" yazan kısımları Twitter Developer hesabınıza özgü olan kodlar ile dolduruyorsunuz. Bu anahtar kodlar her Twitter Developer hesabının benzersiz kodlarıdır ve kimse ile paylaşılmamalıdır.

Tweet’leri Çekme
Bu işlemlerin ardından Twitter’dan tweet çekme işlemine başlayabiliriz. Türkçe dilinde içinde “steam” kelimesinin geçtiği 5000 adet tweet için arama yapıyoruz. Bu işlem sırasında otomatik olarak en fazla 1 hafta geriye gidecek şekilde veri çekiliyor. Anlık olarak çekilebilecek 5000 adet tweet bulunmuyorsa bulunan miktar kadar tweet gelecektir. Çekilen tweetleri data frame’e dönüştürüyoruz ve ardından bu data frame’i ise tweet’leri temizleme işleminde kullanacağımız yeni bir data frame’e dönüştürüyoruz. Gelen tweetleri ise UTF-8 formatına dönüştürüyoruz.
Hangi kelimeyi aratmak istiyorsanız steam kelimesinin yerine onu yazabilirsiniz. (En başta yazan steam kelimesini de değiştirirseniz projede birçok yerde yazan steam kelimesini değiştirmek zorunda kalırsınız, sadece tırnak içerisinde yazan "steam" kelimesini değiştirmeniz yeterlidir.) Kaç adet tweet çekmek istiyorsanız n=5000 yazan kısmı değiştirebilirsiniz.

Çekilen tweet’lerin içeriğini görmek için summary(steam.df) komutu ile inceliyoruz. 16 adet sütun ve 1248 adet satırdan oluştuğunu görebiliyoruz. Ayrıca her sütunun başlığı, veri tipleri, minimum, maksimum, ortalama, 1. Çeyrek, 3. Çeyrek, medyan gibi değerleri de görebiliyoruz.

Bu adımın ardından veri temizleme adımına geçilebilir ancak 1 ay süren bir veri toplama işleminin ardından çekilen tüm tweet’lerin tek bir dosya haline getirilip birleştirilmesinden sonra göstermek tekrarı önlemek açısından daha mantıklı olacaktır. Şimdilik tweet’leri çeker çekmez kaydettiğimizi varsayalım. Tweet’leri nereye kaydetmek istiyorsak dosya konumunu yazdıktan sonra tweet’leri hangi tarihte çektiğimizi belirten bir isimle kaydetmek oldukça faydalı olacaktır. Burada “tweet_clean” yani temizleme işlemi yapılan tweet’leri kaydettim ancak bu adımı bir sonraki aşamaya bıraktığımız için steam data frame’ini kullanarak kaydetmek daha tutarlı olacaktır.

Tweet’leri Birleştirme
Artık tweet’leri Twitter’dan çekmek yerine bilgisayarımızda depoladığımız, butun-tweetler adını verdiğimiz excel dosyasından açıyoruz. Twitter Developer hesabından yaptığımız bağlantıya da ihtiyaç duymuyoruz. Bu sebeple twListToDF komutu artık burada çalışmayacak. Onun yerine as.data.frame komutunu kullanarak tweet’lerimizi tekrar data frame’e çeviriyoruz. Tweet’ler temizlendikten sonra ayrı bir data frame olacağı için tweet_clean adında bir data frame oluşturuyoruz ve UTF-8 formatına dönüştürüyoruz.

Verileri Temizleme
Tweet’leri temizleme işlemine retweet eden kullanıcıların başında bulunan “RT” ifadelerini temizlemekle başlıyoruz. Ardından “http” ile başlayan url linklerini, “#” ve “@” ifadelerini temizliyoruz. Daha sonra ise noktalama işaretlerini ve rakamları da tweetlerden arındırıyoruz ve tüm harfleri küçük harfe çeviriyoruz. Devamında ise ASCII formatına uygun olmayan ve alfabetik olmayan karakterleri siliyoruz.
Daha sonra bir corpus oluşturarak Turkish Stopwords ve Durak Kelimeler adındaki dosyalarımızı da projeye ekleyerek veri temizleme işleminin son adımını gerçekleştiriyoruz.

Bu temizleme işlemlerinin ardından temiz verileri artık butun-tweetler-temiz olarak ayrı bir excel dosyasında depolayabiliriz.

Veri Görselleştirme

Görsel çıktılara bakmak için RPlot dosyalarını inceleyebilirsiniz.

Öncelikle görselleştirilecek olan verinin nereden çekileceği işlemini yapıyoruz. Temizlenmiş olan tweet_clean’dan sütun başlığı text olan, yani tweetlerin olduğu sütunu Turkish Stopwords’e uygun bir şekilde oluşturuyoruz.
Hemen ardından görselleştirme işlemine başlayabiliriz. Tweet’lerde 50 defadan fazla tekrar eden kelimeleri sıralı bir şekilde bar grafiğinde gösteriyoruz.
Daha sonra ise en fazla 100 kelime içerecek şekilde bir kelime bulutu oluşturuyoruz. En fazla tekrar eden kelime en büyük, en az tekrar eden kelime ise en küçük olacak şekilde oranlanmıştır.

Metin madenciliği aşamaları burada sonlanmıştır, sırada duygu analizi aşamaları bulunmaktadır.



DUYGU ANALİZİ ADIM ADIM

Duygu analizi yapmak için öncelikle farklı duygu grupları olması gerekir. Bu projede sadece pozitif, negatif ve nötr duyguları bulunmaktadır. Pozitif ve negatif kelimelerin bulunduğu txt dosyalarını projeye ekliyoruz. Özet bilgilerine summary() komutu ile erişebiliyoruz. İçeriklerinden birkaçını görmek için ise dput() komutunu kullanabiliriz.

Ardından duygu skoru oluşturmak için bir kod bloğu yazıyoruz. Kendi içinde temizleme işlemleri barındırıyor. Duygu analizi için en önemli kısım olan match() komutu ise tweetlerde bulunan kelimeleri pozitif ve negatif kelimeler sözlüğümüzle kıyaslamasıdır. Ancak bu komut bize eşleşen kelimelerin pozitif ve negatif kelimeler sözlüğünde kaçıncı kelimelere denk geldiğinin sonucunu veriyor ve cümlelere duygu analizi yapabilmek için sözlükten kaçıncı kelimeye denk geldiğinden ziyade sözlükten bir kelimeye eşleşip eşleşmediğini bulmamız gerekir. Bu sebeple true/false içeren bir kod eklemesi yapıyoruz. Ardından sum() komutunu kullanarak bir skor formülü oluşturuyoruz. Burada sum() komutu true/false değerlerini 1 ve 0 olarak değerlendirecek. Yani pozitifle eşleşen ve negatifle eşleşmeyen bir cümle skor = 1-0 sonucundan pozitif, pozitifle eşleşmeyen ve negatifle eşleşen bir cümle skor = 0-1 sonucundan negatif, pozitifle eşleşen ve negatifle eşleşen bir cümle veya her ikisiyle de eşleşmeyen bir cümle de skor = 1-1, skor = 0-0 sonuçlarından nötr olacaktır.

Bu kod bloğunun ardından analizi hazırlamak ve duygu skor frekans tablosunu oluşturmak geliyor.

Yukarıdaki skor formülüne göre bir tablo oluşturursak en düşük skor, yani en negatif yorumların skorları -4 çıkmış ve bu skora sahip 2 adet yorum bulunuyor. En yüksek, yani en pozitif yorumların skorları ise 4 çıkmış ve bu skora sahip 6 adet yorum bulunuyor. 4145 adet ise nötr yorum bulunmaktadır.

Bu skor dağılımlarını daha iyi görmek için bir histogram grafiğinde gösterelim. Histogram grafiğini oluştururken ggplot paketini kullanıyoruz.

Son olarak bu skorların 0’ın üzeri pozitif, 0’ın altı negatif ve 0’a eşit olanlarını nötr olarak gruplandırmak kalıyor. Bu aşamada artık pozitif ve negatif değerlerde 0’ın ne kadar üzerinde veya ne kadar altında olduğunun bir önemi kalmıyor. Son grafiği de ggplot paketiyle oluşturuyoruz. Artık 7500 adet tweet’in duygu tipi bar grafiği de oluşmuş oluyor.

Duygu analizinin sonucunda 7500 adet tweet içerisinden büyük çoğunluğu nötr tweetlerin oluşturduğunu görmekteyiz. Yaklaşık 4250 adet nötr tweet bulunuyor. Nötr tweet’lerin ardından ise pozitif tweet’ler geliyor. Yaklaşık 2750 adet pozitif tweet bulunuyor. Son sırada ise negatif tweet’ler bulunuyor. Yaklaşık 600 adet negatif tweet bulunmaktadır. Nötr tweet’ler bütün tweet’lerin yaklaşık %56’sını, pozitif tweet’ler bütün tweet’lerin yaklaşık %36’sını ve negatif tweet’ler ise bütün tweet’lerin yaklaşık %8’ini oluşturmaktadır.

Metin madenciliği ve Duygu Analizi işlemlerinin sonuna gelmiş bulunmaktayız. Kelime bulutu ve histogram grafikleri temel kullanım için yeterli durumdadır ancak isteğinize göre daha çeşitli işlemlerden geçirip daha farklı görsel çıktılar da alabilirsiniz.

19.01.2022
SAMET TURGUT
