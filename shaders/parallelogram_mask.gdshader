shader_type canvas_item;

// 统一变量
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D new_scene;       // 新场景纹理
uniform float progress : hint_range(0, 1);
uniform vec2 screen_size;
uniform float mask_width = 300.0;
uniform float skew_factor = 0.3;
uniform vec4 mask_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);  // 遮罩颜色，默认黑色
uniform float shadow_width = 100.0;  // 阴影宽度
uniform float shadow_intensity = 0.5;  // 阴影强度

void fragment() {
    // 获取当前像素的UV坐标
    vec2 uv = SCREEN_UV;
    vec2 screen_pos = uv * screen_size;
    
    // 计算平行四边形遮罩的中心位置（从右向左移动）
    // progress=0时，遮罩完全在屏幕右侧外；progress=1时，遮罩完全移出屏幕左侧
    float mask_center = screen_size.x + mask_width * 0.5 - progress * (screen_size.x + mask_width);
    
    // 计算倾斜偏移（根据y坐标）
    float skew_offset = (screen_pos.y / screen_size.y - 0.5) * skew_factor * mask_width;
    
    // 平行四边形的左右边界
    float mask_left = mask_center - mask_width * 0.5 + skew_offset;
    float mask_right = mask_center + mask_width * 0.5 + skew_offset;
    
    // 阴影区域（在遮罩左边）
    float shadow_start = mask_left - shadow_width;
    
    // 获取两个场景的颜色
    vec4 old_color = texture(screen_texture, uv);
    vec4 new_color = texture(new_scene, UV);
    
    // 根据位置决定显示内容
    if (screen_pos.x < shadow_start) {
        // 阴影左边：显示旧场景（无阴影）
        COLOR = old_color;
    } else if (screen_pos.x < mask_left) {
        // 阴影区域：旧场景 + 渐变阴影
        float shadow_progress = (screen_pos.x - shadow_start) / shadow_width;
        float shadow_factor = 1.0 - (shadow_progress * shadow_intensity);
        COLOR = old_color * shadow_factor;
    } else if (screen_pos.x < mask_right) {
        // 遮罩区域：显示遮罩颜色（平行四边形本身）
        COLOR = mask_color;
    } else {
        // 遮罩右边：显示新场景
        COLOR = new_color;
    }
}