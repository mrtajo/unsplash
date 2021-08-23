//
//  HomeModel.swift
//  unsplash
//
//  Created by mrtajo on 2021/08/23.
//

import Foundation
import UIKit.UIColor

struct HomeModel {
    // MARK: - Photo
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
}
