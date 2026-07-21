//
//  TermsConditionsScreen.swift
//  Cangkruk
//
//  Created by Ivone Liwang on 12/07/26.
//

import SwiftUI

struct TermsConditionsScreen: View {
    @Environment(RouterViewModel.self) private var router

    var body: some View {
        ZStack(alignment: .top) {
            Color("Background")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    HStack {
                        Text("SYARAT & \nKETENTUAN")
                            .font(.shakyComicBold(size: 35))
                            .foregroundStyle(Color("Primary"))
                            .accessibilityLabel("syarat dan ketentuan")
                            .padding(.top,5)

                        Spacer()
                    }

                    AppLottie(animation: "CangkrukWipe")
                        .frame(width: 200, height: 200)
                        .offset(x: 10, y: -5)
                }
                .screenPadding()
                .padding(.top, 20)
                .zIndex(1)
                // Cap scaling here so the title can't outgrow the fixed-size mascot next to it
                // and destabilize the -105/115 offsets below. The scrollable body text isn't
                // capped, so it still gets full Dynamic Type benefit.
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        termsSection(
                            title: "1. Tentang Aplikasi",
                            body: "Cangkruk adalah aplikasi pembelajaran yang membantu barista pemula mempelajari dasar-dasar menjadi barista mencakup pengetahuan produk, komunikasi dengan pelanggan, dan panduan pelatihan berbasis level. Aplikasi ini berfungsi sebagai panduan belajar (learning guidance) dan alat bantu pelatihan."
                        )

                        termsSection(
                            title: "2. Privasi dan Data",
                            body: "Kami menghargai privasimu sepenuhnya:\nKami tidak mengumpulkan data pribadi kamu.\nKami tidak menyimpan data kamu di server mana pun.\nAplikasi hanya menyediakan materi dan panduan pembelajaran.\nKarena kami tidak mengumpulkan maupun menyimpan data, seluruh catatan atau materi yang kamu buat tetap berada di perangkatmu sendiri dan menjadi tanggung jawabmu."
                        )

                        termsSection(
                            title: "3. Penggunaan Aplikasi",
                            body: "Aplikasi ini ditujukan untuk keperluan pembelajaran dan pelatihan. Kamu setuju menggunakan aplikasi secara wajar dan tidak menyalahgunakannya."
                        )
                        
                        termsSection(
                            title: "4. Sifat Materi Pembelajaran",
                            body: "Materi bersifat panduan dan edukatif, bukan sertifikasi resmi. Cangkruk tidak berafiliasi dengan, dan, bukan pengganti, sertifikasi resmi mana pun (termasuk Specialty Coffee Association / SCA). Penguasaan Keterampilan praktis tetap memerlkukan latihan langsung dan pendampingan. Hasil belajar dapat berbeda pada setiap pengguna."
                        )
                        
                        termsSection(
                            title: "5. Batasan Tanggung Jawab",
                            body: "Aplikasi disediakan sebagaimana adanya. Kami tidak bertanggung jawab atas keputusan, tindakan, atau hasil apa pun yang timbul dari penggunaan panduan dalam aplikasi ini."
                        )
                        
                        termsSection(
                            title: "6. Kekayaan Intelektual",
                            body: "Seluruh konten, desain, dan materi dalam Cangkruk, dilindungi hak kekayaan intelektual. Kamu tidak diperbolehkan menyalin atau mendistribusikan ulang tanpa izin."
                        )
                        
                        termsSection(
                            title: "7. Perubahan",
                            body: "Kami dapat memperbarui Syarat dan Ketentuan ini sewaktu-waktu. Perubahan berlaku sejak dipublikasikan di dalam aplikasi."
                        )
                        
                        termsSection(
                            title: "8. Tentang Pembuat",
                            body: "Cangkruk dikembangkan sebagai proyek pembelajaran di Apple Developer Academy.\n\nDengan menggunakan Cangkruk, kamu menyetujui Syarat dan Ketentuan di atas."
                        )
                    }
                    .padding(25)
                }
                .background(Color("lightBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.top, -105)
                .padding(.bottom, 115)
                .screenPadding()
            }

            VStack {
                Spacer()

                AppButton(label: "Kembali") {
                    router.pop()
                }
                .padding(.bottom, 24)
                .screenPadding()
            }
        }
        .navigationBarBackButtonHidden()
    }

    @ViewBuilder
    private func termsSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.shakyComicBold(size: 20, relativeTo: .subheadline))
                .foregroundStyle(Color("Secondary"))

            Text(body)
                .font(.body)
                .foregroundStyle(Color("Secondary"))
        }
    }
}

#Preview {
    TermsConditionsScreen()
        .environment(RouterViewModel())
}
