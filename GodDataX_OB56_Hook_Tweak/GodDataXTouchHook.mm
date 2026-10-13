/**
 * GODDATAX iOS - Free Fire OB56 Native Touch Hook (.dylib)
 * 
 * Modul Tweak Hook Sumbu X & Y untuk Free Fire iOS.
 * Tweak ini di-inject langsung ke dalam file FreeFire.ipa.
 * 
 * Cara kerja:
 * 1. Meng-hook event sentuhan Unity/UIKit saat pemain menggeser layar di Free Fire.
 * 2. Mengambil rasio Sumbu X dan Y yang telah Anda atur di aplikasi GodDataX.
 * 3. Melipatgandakan delta pergerakan sentuhan secara real-time, sehingga:
 *    -> Walaupun sensitivitas di dalam game Free Fire bernilai 0,
 *       layar tetap berputar kencang dan tarikan drag shot ke kepala musuh sangat enteng!
 */

#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>

// Struktur Konfigurasi Sumbu X & Y
struct GDXTouchConfig {
    BOOL isEnabled;
    float sensX;
    float sensY;
    float responseSpeed;
};

static struct GDXTouchConfig currentConfig = {
    .isEnabled = YES,
    .sensX = 1.80f,
    .sensY = 3.20f,
    .responseSpeed = 1.0f
};

// Fungsi pembaca file konfigurasi dari GodDataX
static void loadGDXConfig(void) {
    NSArray *paths = @[
        @"/var/mobile/Documents/GodDataX_TouchConfig.json",
        [NSTemporaryDirectory() stringByAppendingPathComponent:@"GodDataX_TouchConfig.json"],
        [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"GodDataX_TouchConfig.json"]
    ];
    
    for (NSString *path in paths) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            NSData *data = [NSData dataWithContentsOfFile:path];
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (dict && [dict isKindOfClass:[NSDictionary class]]) {
                    if (dict[@"enabled"]) currentConfig.isEnabled = [dict[@"enabled"] boolValue];
                    if (dict[@"sensitivityX"]) currentConfig.sensX = [dict[@"sensitivityX"] floatValue];
                    if (dict[@"sensitivityY"]) currentConfig.sensY = [dict[@"sensitivityY"] floatValue];
                    if (dict[@"responseSpeed"]) currentConfig.responseSpeed = [dict[@"responseSpeed"] floatValue];
                    NSLog(@"[GodDataX Hook] Loaded Config: enabled=%d, X=%.2f, Y=%.2f", currentConfig.isEnabled, currentConfig.sensX, currentConfig.sensY);
                    return;
                }
            }
        }
    }
}

// Swizzle implementation untuk UITouch locationInView
static CGPoint (*orig_locationInView)(id, SEL, UIView *);

static CGPoint hook_locationInView(UITouch *self, SEL _cmd, UIView *view) {
    CGPoint orig = orig_locationInView(self, _cmd, view);
    
    if (!currentConfig.isEnabled) {
        return orig;
    }
    
    CGPoint prev = [self previousLocationInView:view];
    
    // Hitung pergeseran delta sentuhan
    CGFloat dx = orig.x - prev.x;
    CGFloat dy = orig.y - prev.y;
    
    // Lipatgandakan delta pergerakan dengan sensitivitas Sumbu X dan Y
    CGFloat amplifiedDx = dx * (currentConfig.sensX - 1.0f);
    CGFloat amplifiedDy = dy * (currentConfig.sensY - 1.0f);
    
    return CGPointMake(orig.x + amplifiedDx, orig.y + amplifiedDy);
}

// Inisialisasi Hook saat dylib dimuat oleh Free Fire
__attribute__((constructor))
static void initializeGodDataXHook(void) {
    @autoreleasepool {
        NSLog(@"[GodDataX OB56] Initializing Native Free Fire Touch Hook...");
        
        loadGDXConfig();
        
        // Timer polling konfigurasi setiap 5 detik agar perubahan slider di GodDataX langsung diterapkan
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            while (1) {
                sleep(5);
                loadGDXConfig();
            }
        });
        
        // Swizzle method -[UITouch locationInView:]
        Class uiTouchClass = [UITouch class];
        SEL selector = @selector(locationInView:);
        Method origMethod = class_getInstanceMethod(uiTouchClass, selector);
        
        if (origMethod) {
            orig_locationInView = (CGPoint (*)(id, SEL, UIView *))method_getImplementation(origMethod);
            method_setImplementation(origMethod, (IMP)hook_locationInView);
            NSLog(@"[GodDataX OB56] -[UITouch locationInView:] successfully hooked!");
        } else {
            NSLog(@"[GodDataX OB56] Error: Failed to find -[UITouch locationInView:]");
        }
        
        // Tampilkan subtle banner HUD di atas game
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIWindow *keyWindow = nil;
            for (UIWindow *w in [UIApplication sharedApplication].windows) {
                if (w.isKeyWindow) { keyWindow = w; break; }
            }
            if (keyWindow) {
                UILabel *badge = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 180, 24)];
                badge.text = @" GDX OB56 HOOK ACTIVE ";
                badge.textColor = [UIColor whiteColor];
                badge.backgroundColor = [UIColor colorWithRed:1.0 green:0.12 blue:0.15 alpha:0.8];
                badge.font = [UIFont boldSystemFontOfSize:11];
                badge.layer.cornerRadius = 6;
                badge.layer.masksToBounds = YES;
                badge.textAlignment = NSTextAlignmentCenter;
                [keyWindow addSubview:badge];
                
                // Hilang otomatis setelah 4 detik
                [UIView animateWithDuration:0.8 delay:4.0 options:0 animations:^{
                    badge.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [badge removeFromSuperview];
                }];
            }
        });
    }
}
