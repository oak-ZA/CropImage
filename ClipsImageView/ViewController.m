//
//  ViewController.m
//  ClipsImageView
//
//  Created by 张奥 on 2020/9/17.
//  Copyright © 2020 oak. All rights reserved.
//

#import "ViewController.h"
#import "TZImagePickerController.h"
#import "RSKImageCropViewController.h"
#import "CustomCollectionViewCell.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<TZImagePickerControllerDelegate,RSKImageCropViewControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) NSMutableArray *croppedImages;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.images = [NSMutableArray array];
    self.croppedImages = [NSMutableArray array];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 80, 80);
    button.backgroundColor = [UIColor redColor];
    [button addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 8.f;
    [self.view addSubview:button];
    
    [self createCollectionView];
}

-(void)createCollectionView{
    CGFloat width = (SCREEN_WIDTH - (50*2+2*10))/3;
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 10;
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemSize = CGSizeMake(width, width);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(50, 280, SCREEN_WIDTH, width) collectionViewLayout:flowLayout];
    self.collectionView = collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerNib:[UINib nibWithNibName:@"CustomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:collectionView];
    if (@available(iOS 11.0,*)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePressMoving:)];
    self.longPress = longPress;
    [collectionView addGestureRecognizer:longPress];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 3;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CustomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    if (self.croppedImages.count > 0) {
        UIImage *image = self.croppedImages[indexPath.row];
        cell.imageView.image = image;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)lonePressMoving:(UILongPressGestureRecognizer *)longPress{
      switch (longPress.state) {
            case UIGestureRecognizerStateBegan: {
                {
                    NSIndexPath *selectIndexPath = [self.collectionView indexPathForItemAtPoint:[longPress locationInView:self.collectionView]];
                    // 找到当前的cell
//                    CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:selectIndexPath];
                    // 定义cell的时候btn是隐藏的, 在这里设置为NO
//                    [cell.btnDelete setHidden:NO];
                    [self.collectionView beginInteractiveMovementForItemAtIndexPath:selectIndexPath];
                }
                break;
            }
            case UIGestureRecognizerStateChanged: {
                    [self.collectionView updateInteractiveMovementTargetPosition:[longPress locationInView:longPress.view]];
                break;
            }
            case UIGestureRecognizerStateEnded: {
                    [self.collectionView endInteractiveMovement];
                break;
            }
            default: [self.collectionView cancelInteractiveMovement];
                break;
        }
}

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(nonnull NSIndexPath *)sourceIndexPath toIndexPath:(nonnull NSIndexPath *)destinationIndexPath
{
    NSIndexPath *selectIndexPath = [self.collectionView indexPathForItemAtPoint:[_longPress locationInView:self.collectionView]];
    // 找到当前的cell
//    CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:selectIndexPath];
//    [cell.btnDelete setHidden:YES];
    [self.croppedImages exchangeObjectAtIndex:sourceIndexPath.item withObjectAtIndex:destinationIndexPath.item];
    [self.collectionView reloadData];
}

-(void)clickBtn{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:3 delegate:self];


    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
      
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    if (photos.count > 0) {
        [self.images addObjectsFromArray:photos];
        RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:photos[0] cropMode:RSKImageCropModeSquare];
        imageCropVC.delegate = self;
        [self.navigationController pushViewController:imageCropVC animated:YES];
        [self.images removeObjectAtIndex:0];
    }
}
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos{
    
}
- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker{
    
}

// If user picking a video and allowPickingMultipleVideo is NO, this callback will be called.
// If allowPickingMultipleVideo is YES, will call imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
// 如果用户选择了一个视频且allowPickingMultipleVideo是NO，下面的代理方法会被执行
// 如果allowPickingMultipleVideo是YES，将会调用imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset{
    
}

// If user picking a gif image and allowPickingMultipleVideo is NO, this callback will be called.
// If allowPickingMultipleVideo is YES, will call imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
// 如果用户选择了一个gif图片且allowPickingMultipleVideo是NO，下面的代理方法会被执行
// 如果allowPickingMultipleVideo是YES，将会调用imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingGifImage:(UIImage *)animatedImage sourceAssets:(PHAsset *)asset{
    
}

// Decide album show or not't
// 决定相册显示与否 albumName:相册名字 result:相册原始数据
- (BOOL)isAlbumCanSelect:(NSString *)albumName result:(PHFetchResult *)result{
    return YES;
}

// Decide asset show or not't
// 决定照片显示与否
- (BOOL)isAssetCanSelect:(PHAsset *)asset{
    return YES;
}




#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(nonnull RSKImageCropViewController *)controller didCropImage:(nonnull UIImage *)croppedImage usingCropRect:(CGRect)cropRect rotationAngle:(CGFloat)rotationAngle {
    if (croppedImage) {
        [self.croppedImages addObject:croppedImage];
    }
    [self.navigationController popViewControllerAnimated:NO];
    if (self.images.count > 0) {
        UIImage *image = self.images[0];
        RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeSquare];
        imageCropVC.delegate = self;
        [self.navigationController pushViewController:imageCropVC animated:NO];
        [self.images removeObjectAtIndex:0];
    }else{
        [self.collectionView reloadData];
    }
}


- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage{
    
    
}

@end
