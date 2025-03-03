# LoRA train script by @Akegarasu modify by @bdsqlsz and @LinXudong

# Train data path | 设置训练用模型、图片
$pretrained_model = "./sd-models/v1-5-pruned-emaonly.safetensors" # base model path | 底模路径
$train_data_dir = "./train/images" # train dataset path | 训练数据集路径
$reg_data_dir = "" # directory for regularization images | 正则化数据集路径，默认不使用正则化图像。

# Network settings | 网络设置
$network_weights = "" # pretrained weights for LoRA network | 若需要从已有的 LoRA 模型上继续训练，请填写 LoRA 模型路径。
$network_dim = 128 # network dim | 常用 4~128，不是越大越好
$network_alpha = 64 # network alpha | 常用与 network_dim 相同的值或者采用较小的值，如 network_dim的一半 防止下溢。默认值为 1，使用较小的 alpha 需要提升学习率。

# Train related params | 训练相关参数
$resolution = "768,768" # image resolution w,h. 图片分辨率，宽,高。支持非正方形，但必须是 64 倍数。
$batch_size = 1 # batch size 一次性训练图片批处理数量，根据显卡质量对应调高。
$max_train_epoches = 20 # max train epoches | 最大训练 epoch
$save_every_n_epochs = 1 # save every n epochs | 每 N 个 epoch 保存一次

$train_unet_only = 0 # train U-Net only | 仅训练 U-Net，开启这个会牺牲效果大幅减少显存使用。6G显存可以开启
$train_text_encoder_only = 0 # train Text Encoder only | 仅训练 文本编码器

$noise_offset = 0 # noise offset | 在训练中添加噪声偏移来改良生成非常暗或者非常亮的图像，如果启用，推荐参数为 0.1
$keep_tokens = 0 # keep heading N tokens when shuffling caption tokens | 在随机打乱 tokens 时，保留前 N 个不变。
$shuffle_caption= 1 # 打乱逗号分隔的caption元素

# Learning rate | 学习率
$lr = "1.2e-5" # 填入DAdaptation跑出的学习率
$lr /= 3 # 最佳效果使用DAdaptation跑出的学习率除以三，然后用Lion跑，虽然loss值不是最低，但是效果是最好，最高可以调整到除以二，loss值低，效果也可以。
$unet_lr = $lr # 和学习率一致
$text_encoder_lr = $lr / 2 # 学习率的一半
$lr_scheduler = "cosine_with_restarts" # "linear", "cosine", "cosine_with_restarts", "polynomial", "constant", "constant_with_warmup"

# 打印学习率
"学习率设置：lr={0:0.00e+0}，unet_lr={1:0.00e+0}，text_encoder_lr={2:0.00e+0}" -f $lr,$unet_lr,$text_encoder_lr

$lr_warmup_steps = 0 # warmup steps | 仅在 lr_scheduler 为 constant_with_warmup 时需要填写这个值
$lr_restart_cycles = 1 # cosine_with_restarts restart cycles | 余弦退火重启次数，仅在 lr_scheduler 为 cosine_with_restarts 时起效。

# Output settings | 输出设置
$output_name = "images" # output model name | 模型保存名称
$save_model_as = "safetensors" # model save ext | 模型保存格式 ckpt, pt, safetensors

# 其他设置
$bucket_reso_steps = 64 # bucket的分辨率单位，建议用8的倍数，步进默认64
$bucket_no_upscale = 1 # 在不放大图像的情况下创建包
$min_bucket_reso = 512 # arb min resolution | arb 最小分辨率
$max_bucket_reso = 768 # arb max resolution | arb 最大分辨率
$persistent_data_loader_workers = 0 # persistent dataloader workers | 容易爆内存，保留加载训练集的worker，减少每个 epoch 之间的停顿
$clip_skip = 2 # clip skip | 玄学 一般用 2

$mixed_precision = "fp16" # bf16效果更好但是旧显卡不支持，默认fp16
$save_precision = "fp16" # 保存的格式
$use_xformers = 1 # 有助于减少显存使用，推荐开启

# 优化器设置
$optimizer_type = "Lion" # "adaFactor","AdamW","AdamW8bit","Lion","SGDNesterov","SGDNesterov8bit","DAdaptation",  推荐 新优化器Lion。推荐学习率unetlr=lr=6e-5,tenclr=7e-6


# LyCORIS 训练设置
$enable_LyCORIS = 1 # enable LoCon train | 启用 LoCon 训练 启用后 network_dim 和 network_alpha 应当选择较小的值，比如 2~16
$algo = "lora" # LyCORIS network algo | LyCORIS 网络算法 可选 lora、loha。lora即为locon
$conv_dim = 4 # conv dim | 类似于 network_dim，推荐为 4
$conv_alpha = 4 # conv alpha | 类似于 network_alpha，可以采用与 conv_dim 一致或者更小的值


# 学习途中的样品输出 通过在学习中的模型中尝试生成图像，可以确认学习的进展方法。
# 要进行样品输出，必须预先准备好写有提示的文本文件。每行用一个提示来描述。
$sample_prompts = "./train/images/sample.txt" # 样本配置文件的路径
# 例如，如下所示：
# masterpiece, best quality, 1girl, in white shirts, upper body, looking at viewer, simple background --n low quality, worst quality, bad anatomy,bad composition, poor, low effort --w 768 --h 768 --d 1 --l 7.5 --s 30
# --n将下一个选项作为消极提示。
# --w指定生成图像的宽度。
# --h指定生成图像的高度。
# --d指定生成图像的seed。
# --l指定生成图像的CFG scale。
# --s指定生成时的步数。

# 指定要输出样本的步数或Epoku数。按这个数字输出样品。如果双方都指定的话，Epoku数会优先。
$sample_every_n_steps = 0 # 指定步数生成样品图像
$sample_every_n_epochs = 1 # 指定epoch数生成样品图像

# 指定用于样品输出的取样器。'ddim', 'pndm', 'heun', 'dpmsolver', 'dpmsolver++', 'dpmsingle', 'k_lms', 'k_euler', 'k_euler_a', 'k_dpm_2', 'k_dpm_2_a'可以选择。
$sample_sampler = "k_euler_a" 

# ============= DO NOT MODIFY CONTENTS BELOW | 请勿修改下方内容 =====================
# Activate python venv
.\venv\Scripts\activate

$network_module = "networks.lora"
$Env:HF_HOME = "huggingface"

$ext_args = [System.Collections.ArrayList]::new()
$optimizer_args = [System.Collections.ArrayList]::new()

if ($train_unet_only) {
  [void]$ext_args.Add("--network_train_unet_only")
}

if ($train_text_encoder_only) {
  [void]$ext_args.Add("--network_train_text_encoder_only")
}


if ($enable_LyCORIS) {
  $network_module = "lycoris.kohya"
  [void]$ext_args.Add("--network_args")
  [void]$ext_args.Add("conv_dim=$conv_dim")
  [void]$ext_args.Add("conv_alpha=$conv_alpha")
  [void]$ext_args.Add("algo=$algo")
}


if($optimizer_type -ieq "adafactor") {
	[void]$ext_args.Add("--optimizer_type=" + $optimizer_type)
	[void]$optimizer_args.Add("scale_parameter=True")
	[void]$optimizer_args.Add("warmup_init=True")
	[void]$ext_args.Add("--optimizer_args=" + $optimizer_args)
}

if($optimizer_type -ieq "DAdaptation") {
	[void]$ext_args.Add("--optimizer_type=" + $optimizer_type)
	[void]$optimizer_args.Add("decouple=True")
	$lr = "1"
	$unet_lr = "1"
	$text_encoder_lr = "0.5"
	[void]$ext_args.Add("--optimizer_args=" + $optimizer_args)
}

if($optimizer_type -ieq "Lion") {
	$optimizer_type=""
	[void]$ext_args.Add("--use_lion_optimizer")
}

if($optimizer_type -ieq "AdamW8bit") {
	$optimizer_type=""
	[void]$ext_args.Add("--use_8bit_adam")
}

if ($network_weights) {
  [void]$ext_args.Add("--network_weights=" + $network_weights)
}
if ($bucket_no_upscale) {
  [void]$ext_args.Add("--bucket_no_upscale")
}
if ($reg_data_dir) {
  [void]$ext_args.Add("--reg_data_dir=" + $reg_data_dir)
}

if ($sample_prompts)
{
	if ($sample_every_n_epochs) {
		[void]$ext_args.Add("--sample_every_n_epochs=$sample_every_n_epochs")
	}
	if ($sample_every_n_steps) {
		[void]$ext_args.Add("--sample_every_n_steps=$sample_every_n_steps")
	}
	if ($sample_sampler) {
		[void]$ext_args.Add("--sample_sampler=$sample_sampler")
	}
	[void]$ext_args.Add("--sample_prompts=$sample_prompts")
}

if ($shuffle_caption) {
	[void]$ext_args.Add("--shuffle_caption")
}

if ($persistent_data_loader_workers) {
  [void]$ext_args.Add("--persistent_data_loader_workers")
}

if ($keep_tokens) {
	[void]$ext_args.Add("--keep_tokens=$keep_tokens")
}

if ($bucket_reso_steps) {
	[void]$ext_args.Add("--bucket_reso_steps=$bucket_reso_steps")
}

if ($noise_offset) {
  [void]$ext_args.Add("--noise_offset=$noise_offset")
}


if ($use_xformers) {
	[void]$ext_args.Add("--xformers")
}

# run train
accelerate launch --num_cpu_threads_per_process=8 "./sd-scripts/train_network.py" `
  --enable_bucket `
  --no_metadata `
  --pretrained_model_name_or_path=$pretrained_model `
  --train_data_dir=$train_data_dir `
  --output_dir="./output" `
  --logging_dir="./logs" `
  --resolution=$resolution `
  --network_module=$network_module `
  --max_train_epochs=$max_train_epoches `
  --learning_rate=$lr `
  --unet_lr=$unet_lr `
  --text_encoder_lr=$text_encoder_lr `
  --lr_scheduler=$lr_scheduler `
  --lr_warmup_steps=$lr_warmup_steps `
  --lr_scheduler_num_cycles=$lr_restart_cycles `
  --network_dim=$network_dim `
  --network_alpha=$network_alpha `
  --output_name=$output_name `
  --train_batch_size=$batch_size `
  --save_every_n_epochs=$save_every_n_epochs `
  --mixed_precision=$mixed_precision `
  --save_precision=$save_precision `
  --seed="1337" `
  --cache_latents `
  --clip_skip=$clip_skip `
  --prior_loss_weight=1 `
  --max_token_length=225 `
  --caption_extension=".txt" `
  --save_model_as=$save_model_as `
  --min_bucket_reso=$min_bucket_reso `
  --max_bucket_reso=$max_bucket_reso `
  $ext_args

Write-Output "Train finished"
Read-Host | Out-Null ;