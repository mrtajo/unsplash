//
//  Photos.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/01.
//

import Foundation
import UIKit

struct Photo: Decodable {
    let id: String
    let createdAt: String
    let updatedAt: String
    let width: Int
    let height: Int
    let color: String
    let blurHash: String
    let likes: Int
    let likedByUser: Bool
    let description: String?
    let user: User
    let currentUserCollections: [Collection]
    let urls: PhotoUrls
    let links: PhotoLinks
    
    enum CodingKeys: String, CodingKey {
        case id, width, height, color, likes, description, user, urls, links
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case blurHash = "blur_hash"
        case likedByUser = "liked_by_user"
        case currentUserCollections = "current_user_collections"
    }
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(String.self, forKey: .id)
//        createdAt = try container.decode(String.self, forKey: .createdAt)
//        updatedAt = try container.decode(String.self, forKey: .updatedAt)
//        width = try container.decode(Int.self, forKey: .width)
//        height = try container.decode(Int.self, forKey: .height)
//        color = try container.decode(String.self, forKey: .color)
//        blurHash = try container.decode(String.self, forKey: .blurHash)
//        likes = try container.decode(Int.self, forKey: .likes)
//        likedByUser = try container.decode(Bool.self, forKey: .likedByUser)
//        description = try container.decode(String.self, forKey: .description)
//        user = try container.decode(User.self, forKey: .user)
//        currentUserCollections = try container.decode([Collection].self, forKey: .currentUserCollections)
//        urls = try container.decode(PhotoUrls.self, forKey: .urls)
//        links = try container.decode(PhotoLinks.self, forKey: .links)
//    }
}

// MARK: - User
struct User: Decodable {
    let id: String
    let username: String
    let name: String
    let portfolioUrl: String?
    let bio: String?
    let location: String?
    let totalLikes: Int
    let totalPhotos: Int
    let totalCollections: Int
    let instagramUsername: String?
    let twitterUsername: String?
    let profileImage: UserImage
    let links: UserLinks
    
    enum CodingKeys: String, CodingKey {
        case id, username, name, bio, location, links
        case portfolioUrl = "portfolio_url"
        case totalLikes = "total_likes"
        case totalPhotos = "total_photos"
        case totalCollections = "total_collections"
        case instagramUsername = "instagram_username"
        case twitterUsername = "twitter_username"
        case profileImage = "profile_image"
    }
    
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(String.self, forKey: .id)
//        username = try container.decode(String.self, forKey: .username)
//        name = try container.decode(String.self, forKey: .name)
//        portfolioUrl = try container.decode(String.self, forKey: .portfolioUrl)
//        bio = try container.decode(String.self, forKey: .bio)
//        location = try container.decode(String.self, forKey: .location)
//        totalLikes = try container.decode(Int.self, forKey: .totalLikes)
//        totalPhotos = try container.decode(Int.self, forKey: .totalPhotos)
//        totalCollections = try container.decode(Int.self, forKey: .totalCollections)
//        instagramUsername = try container.decode(String.self, forKey: .instagramUsername)
//        twitterUsername = try container.decode(String.self, forKey: .twitterUsername)
//        profileImage = try container.decode(UserImage.self, forKey: .profileImage)
//        links = try container.decode(UserLinks.self, forKey: .links)
//    }
}

struct UserImage: Decodable {
    let small: String
    let medium: String
    let large: String
}

struct UserLinks: Decodable {
    let `self`: String
    let html: String
    let photos: String
    let likes: String
    let portfolio: String
}

// MARK: - Collection
struct Collection: Decodable {
    let id: Int
    let title: String
    let publishedAt: String
    let lastCollectedAt: String
    let updatedAt: String
    let coverPhoto: String?
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case id, title, user
        case publishedAt = "published_at"
        case lastCollectedAt = "last_collected_at"
        case updatedAt = "updated_at"
        case coverPhoto = "cover_photo"
    }
}

// MARK: - PhotoUrls
struct PhotoUrls: Decodable {
    let raw: String
    let full: String
    let regular: String
    let small: String
    let thumb: String
}

// MARK: - PhotoLinks
struct PhotoLinks: Decodable {
    let `self`: String
    let html: String
    let download: String
    let downloadLocation: String
    
    enum CodingKeys: String, CodingKey {
        case `self`, html, download
        case downloadLocation = "download_location"
    }
}
