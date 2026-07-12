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
                        Image("termsConditionsTitle")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 70)

                        Spacer()
                    }

                    AppLottie(animation: "CangkrukWipe")
                        .frame(width: 185)
                        .offset(x: -8, y: -5)
                }
                .padding(.horizontal, 30)
                .padding(.top, 20)
                .zIndex(1)

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
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding(.top, -105)
                .padding(.horizontal, 30)
            }

            VStack {
                Spacer()

                AppImageButton(imageName: "kembaliButton") {
                    router.pop()
                }
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden()
    }

    @ViewBuilder
    private func termsSection(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3)
                .bold()
                .foregroundStyle(.black)

            Text(body)
                .font(.body)
                .foregroundStyle(.black.opacity(0.75))
        }
    }
}

#Preview {
    TermsConditionsScreen()
        .environment(RouterViewModel())
}
