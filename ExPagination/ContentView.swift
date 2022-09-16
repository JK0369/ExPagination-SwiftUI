//
//  ContentView.swift
//  ExPagination
//
//  Created by 김종권 on 2022/09/17.
//

import SwiftUI
import Combine

struct ContentView: View {
  @State var page = 0
  @State var isAppear = false
  @State var photos = [Photo]()
  @State var cancellables = Set<AnyCancellable>()
  
  var body: some View {
    NavigationView {
      getList(items: $photos)
    }
    .onAppear {
      guard !isAppear else { return }
      isAppear = true
      loadMorePhotos()
    }
  }
  
  @ViewBuilder
  private func getList(items: Binding<[Photo]>) -> some View {
    List {
      ForEach(items.wrappedValue, id: \.id) { photo in
        ZStack {
          NavigationLink(
            destination: {
              // EmptyView는 테스트를 위해 넣은것이고, 별도의 DetailView() 정의하여 이곳에 사용할것
              EmptyView()
            },
            label: {
              EmptyView()
            }
          )
          .opacity(0)
          .buttonStyle(PlainButtonStyle())
          
          HStack {
            getRowView(photo: photo)
          }
        }
        .listRowInsets(.init())
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 4, trailing: 0))
      }
      if !items.isEmpty {
        HStack {
          Spacer()
          ProgressView()
            .onAppear {
              print("여기")
              loadMorePhotos()
            }
          Spacer()
        }
      }
    }
    .listStyle(PlainListStyle())
    .navigationTitle("photo")
  }
  
  @ViewBuilder
  private func getRowView(photo: Photo) -> some View {
    AsyncImage(
      url: URL(string: photo.urls.regular),
      content: { image in
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width * photo.height / photo.width)
      },
      placeholder: { ProgressView() }
    )
  }
  
  private func loadMorePhotos() {
    page += 1
    self.cancellables = Set<AnyCancellable>()
    API.fetchPhotos(page: page)
      .sink(
        receiveCompletion: {
          switch $0 {
          case .finished:
            break
          case let .failure(error):
            print(error.localizedDescription)
          }
        }, receiveValue: { data in
          guard let photos = try? JSONDecoder().decode([Photo].self, from: data) else { return }
          self.photos += photos
        }
      )
      .store(in: &self.cancellables)
  }
}
