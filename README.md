🕵️‍♂️ Lie Detector AI

🇹🇷 Türkçe Açıklama
Yalan Dedektörü AI, Flutter ile geliştirilmiş ileri düzey bir simülasyon ve eğlence uygulamasıdır. Sıradan şaka uygulamalarının aksine, bu proje yalan söyleme belirtilerini analiz etmek için cihazın gerçek donanım sensörlerini ve Yapay Zekayı (Google ML Kit) kullanır.

🚀 Temel Özellikler (4 Aşamalı Analiz Sistemi)
Uygulama, doğruluğu test etmek için 4 farklı biyometrik yöntem kullanır:

1. 👤 Yapay Zeka Yüz Analizi (Mikro-Mimikler)
Teknoloji: Google ML Kit Yüz Tespiti.

Nasıl Çalışır: Kullanıcının yüzünü anlık olarak takip eder.

Göz Kaçırma: Kişinin kafasını sağa/sola çevirip göz temasını kestiğini yakalar.

Gerginlik Analizi: Gülümseme oranını ölçerek surat ifadesindeki donukluğu tespit eder.

Yüz Kilidi: Kamera yüzü tam olarak algılamadan tarama başlamaz.

2. ❤️ Kalp Ritmi Ölçümü (PPG Teknolojisi)
Teknoloji: Kamera Görüntü İşleme & Flaş.

Nasıl Çalışır: Fotopletismografi (PPG) mantığını kullanır. Arka flaşı açarak parmak ucundaki kan akışına bağlı renk değişimlerini (Kırmızılık oranını) analiz eder ve nabız artışını simüle eder.

3. 🎙️ Ses Stres Analizi (VSA)
Teknoloji: Mikrofon & Desibel Ölçer.

Nasıl Çalışır: Kullanıcı konuşurken sesin şiddetini ve dalgalanmasını kaydeder. Aşırı yüksek (bağırma) veya aşırı kısık (güvensiz) ses tonlarını stres belirtisi olarak algılar.

4. 🫳 El Titreme Dedektörü (Biyometrik)
Teknoloji: İvmeölçer (Accelerometer) Sensörleri.

Nasıl Çalışır: Kullanıcı parmağını ekrana basılı tutarken elindeki mikro titremeleri ölçer. Sabit duramayan bir el, yalan ve stres göstergesi olarak kabul edilir.

🇺🇸 English Description
Lie Detector AI is an advanced simulation and entertainment application developed with Flutter. Unlike standard prank apps, this project utilizes the device's real hardware sensors and Artificial Intelligence (Google ML Kit) to analyze physiological signs associated with lying.

🚀 Core Features (4-Way Analysis System)
This application performs truth analysis using 4 distinct methods:

1. 👤 AI Face Analysis (Micro-Expressions)
Technology: Google ML Kit Face Detection.

How it works: It tracks the user's face in real-time.

Gaze Aversion: Detects if the user is looking away (Head Euler Angle Y).

Micro-Tension: Analyzes smiling probability to detect facial stiffness.

Face Lock: The scan only starts when the face is perfectly aligned within the frame.

2. ❤️ Heart Rate Monitor (PPG Technology)
Technology: Camera Image Stream & Flashlight.

How it works: Uses Photoplethysmography (PPG) logic. By turning on the flash and analyzing the redness intensity of the fingertip through the camera stream, it estimates the heart rate variability. High BPM indicates stress.

3. 🎙️ Voice Stress Analysis (VSA)
Technology: Microphone & Decibel Meter.

How it works: Records the user's voice while speaking. It analyzes amplitude and intensity. Sudden spikes or extremely low tones are flagged as potential stress indicators.

4. 🫳 Hand Tremor Detection (Biometric)
Technology: Accelerometer & Gyroscope Sensors.

How it works: While the user holds their finger on the scanner button, the app reads micro-movements of the hand. High tremor levels indicate nervousness and stress.

🛠️ Tech Stack
Framework: Flutter & Dart

AI Engine: Google ML Kit

Hardware Access: Camera, Microphone, Flashlight, Haptic Feedback, Accelerometer.

State Management: setState (Optimized for performance).

Architecture: Clean & Modular Architecture.
