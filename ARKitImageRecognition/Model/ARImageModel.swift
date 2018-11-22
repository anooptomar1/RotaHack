//
//  ARImageModel.swift
//  ARKitImageRecognition
//
//  Created by Vlad Bonta on 17/11/2018.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

enum ImageType {
    //Done
    case info
    //Done
    case image
    //Done
    case localImage
    
    case video
    //Done
    case localVideo
    //Done
    case scene
    
    case web
}

class ARImageModel {
    var title: String = ""
    var imageName: String = ""
    var imageURL: String = ""
    var onlineImageURL: String?
    var imageType: ImageType = .image
    var latitude: Float = 0.0
    var longitude: Float = 0.0
    var videoURL: String?
    var sceneURL: String?
    var infoImageDescription: String?
    var infoImageURL: String?
    var webURL: String?
    
    init() {
        
    }
    
    init(title: String,
         imageName: String,
         imageURL: String,
         imageType: ImageType,
         onlineImageURL: String? = nil,
         videoURL: String? = nil,
         sceneURL: String? = nil,
         infoImageDescription: String? = nil,
         infoImageURL: String? = nil,
         webURL: String? = nil) {
        self.title = title
        self.imageName = imageName
        self.imageURL = imageURL
        self.imageType = imageType
        self.onlineImageURL = onlineImageURL
        self.videoURL = videoURL
        self.sceneURL = sceneURL
        self.infoImageURL = infoImageURL
        self.infoImageDescription = infoImageDescription
        self.webURL = webURL
    }
    
    static func dummy() -> [ARImageModel] {
        var images: [ARImageModel] = []
        
        //Local video
        var ARImage = ARImageModel.init(title: "Image1",
                                        imageName: "iMac 21.5-inch",
                                        imageURL: "imageURL",
                                        imageType: .localVideo,
                                        videoURL: "Antutu")
        images.append(ARImage)
        
        
        //Local image
        ARImage = ARImageModel.init(title: "Image2",
                                    imageName: "iPad 9.7-inch",
                                    imageURL: "2",
                                    imageType: .localImage,
                                    onlineImageURL: "2")
        
        images.append(ARImage)
        
        //Video from url with antutu
        ARImage = ARImageModel.init(title: "Image3",
                                    imageName: "iPad Pro 10.5-inch",
                                    imageURL: "2",
                                    imageType: .video,
                                    videoURL: "https://firebasestorage.googleapis.com/v0/b/rotahack-965d9.appspot.com/o/Antutu.mp4?alt=media&token=54f09452-0135-4220-aac7-4fa546dbc537")
        images.append(ARImage)
        
        //Info view
        ARImage = ARImageModel.init(title: "Ács Alajos",
                                    imageName: "AcsAlajos",
                                    imageURL: "2",
                                    imageType: .info,
                                    infoImageDescription: "     Membru fondator, fost director și actor al Trupei Harag György a Teatrului de Nord Satu Mare. Festivitatea va avea loc în sala studio al teatrului, sală care îi poartă și numele.",
                                    infoImageURL: "http://mek.oszk.hu/02100/02139/html/img/14a.jpg")
        
        images.append(ARImage)
        
        //Scene
        
        ARImage = ARImageModel.init(title: "Working Tools",
                                    imageName: "WorkingTools",
                                    imageURL: "2",
                                    imageType: .scene,
                                    sceneURL: "art.scnassets/WorkingTools.scn")
        images.append(ARImage)
        
        //Video
        ARImage = ARImageModel.init(title: "Working Bench",
                                    imageName: "WorkingBench",
                                    imageURL: "2",
                                    imageType: .video,
                                    videoURL: "https://firebasestorage.googleapis.com/v0/b/rotahack-965d9.appspot.com/o/Documentary.mp4?alt=media&token=aa8f7e8b-6f43-4fa3-a205-da5993ea2663")
        images.append(ARImage)
        
        //Real image - Fuego
        ARImage = ARImageModel.init(title: "Fuego Concert",
                                    imageName: "Fuego",
                                    imageURL: "2",
                                    imageType: .web,
                                    webURL: "https://startickets.ro/FUEGOCOLINDATORLAPORTILECERULUI!/16659")
        images.append(ARImage)
        
        //Real image - Purse
        ARImage = ARImageModel.init(title: "Purses",
                                    imageName: "Purses",
                                    imageURL: "2",
                                    imageType: .info,
                                    infoImageDescription: "     From the earliest stages of civilization, bags and purses were practical everyday articles used by men as well as women. They were necessary for carrying money and other personal items, since clothes hadn’t yet been fitted out with pockets. We know what they looked like from paintings, prints and tapestries and the few historical handbags preserved in museums. Such antique bags are rare because they were mostly made out of perishable materials. \nBags and purses came in a variety of designs for a number of purposes, such as bags with clasps, leather pouches and purses with long drawstrings. With the exception of some rare shoulder bags, these were all worn attached to the belt or girdle. The introduction of pockets towards the end of the 16th century meant that the men’s bags slowly disappeared in the course of the 17th century. From then on, bags belonged almost exclusively to the women’s domain.\nFrom the 16th century onwards, women often wore their purses on a chatelaine; a hook with chains to which small utensils could be attached, such as keys, knife cases, scissors and sewing tools. Since chatelaines were often crafted from precious metals they were also considered as jewellery and status symbols. The design and accessories of the chatelaine evolved in the course of the centuries, but it wasn’t until the beginning of the 20th century that the handbag finally replaced it.\nIn the 17th and 18th centuries and most of the 19th century, women’s clothing was so voluminous that one or two bags or “pockets” could easily be hidden underneath the skirt. Such pockets were usually worn in pairs: one hanging from each hip – hence the name thigh pockets. Thigh pockets remained en vogue for most of the 19th century.",
                                    infoImageURL: "https://i.pinimg.com/236x/3e/cb/a2/3ecba296e697beaaba9c670fe12d8a04--vintage-leather-messenger-bag-vintage-leather-bags.jpg")
        images.append(ARImage)
        
        
        //WEB- Paint
        ARImage = ARImageModel.init(title: "Painters",
                                    imageName: "Paint",
                                    imageURL: "2",
                                    imageType: .web,
                                    webURL: "https://en.wikipedia.org/wiki/History_of_painting")
        images.append(ARImage)
        
        //Local image
        ARImage = ARImageModel.init(title: "Mestesugarilor",
                                    imageName: "Courtain",
                                    imageURL: "Mestesugarilor",
                                    imageType: .localImage,
                                    onlineImageURL: "Mestesugarilor")
        
        images.append(ARImage)
        

        return images
    }
    
}
