/*
ENTRYディレクティブ: リセット時に一番最初に実行される関数 (エントリーポイント) を引数に指定する
Reset_Handlerがエントリーポイントとして指定されている
*/
ENTRY(Reset_Handler)

/*
MEMORYセクション
これらの定義により, ROMとRAMの物理的な配置が指定される
*/
MEMORY {
    /*
    読み取り・実行が可能 (rx)
    開始アドレス: 0x10000000
    長さ: 2048K (2MB)
    */
    ROM (rx)    : ORIGIN = 0x10000000, LENGTH = 2048K
    /*
    読み取り・書き込み・実行が可能 (xrw)
    開始アドレス: 0x20000000
    長さ: 256K
    */
    RAM (xrw)   : ORIGIN = 0x20000000, LENGTH = 256K
}

/*
SECTIONSセクション
メモリ内に各セクションをどのように配置するかを定義する
*/
SECTIONS {
    /*
    セカンドステージブートローダのセクション (__attribute__でセクション名を指定)
    ROMの先頭に配置し大きさは256バイト
    */
    boot2 : {
        __boot2_start__ = .;
        KEEP (*(.boot2))
        __boot2_end__ = .;
    } > ROM
    /* ブートローダのサイズを正確に256バイトと成約している (ASSERTディレクティブ) */
    ASSERT(__boot2_end__ - __boot2_start__ == 256,
        "ERROR: Pico second stage bootloader must be 256 bytes in size")

    /*
    実行コード (プログラム本体) を配置
    ベクタテーブルや読み取り専用データ (.rodata) もここに含む
    .vector: ベクタテーブル (割り込みハンドラやリセットベクタ, 例外ベクタテーブル) を保持 (__attribute__でセクション名を指定)
    .text: 通常のコード
    .rodata: 読み取り専用データ (文字列リテラルや定数など)
    ROMに配置
    */
    .text : {
        __vector_org = .;
        KEEP (*(.vector))

        *(EXCLUDE_FILE(*libgcc.a: *libc.a:*lib_a-mem*.o *libm.a:) .text*)

        __start = .;
        *(.text)
        *(.text.*)
        *(.rodata)
        *(.rodata.*)
    } > ROM

    /*
    アームアーキテクチャ特有のセクションで, 例外処理 (C++のtry-catchなど) 用の情報を格納
    ROMに配置
    .ARM.extab: 例外ハンドリング情報を保持
    .ARM.exidx: 例外ハンドリング用のインデックス
    */
    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
    } > ROM

    __exidx_start = .;
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } > ROM
    __exidx_end = .;

    /*
    初期化済みの変数を配置
    ROMに保存され, 実行時にRAMへコピーされる
    __data_org: ROM内のデータ開始位置
    __data_start: RAM内でデータがコピーされる開始位置
    __data_end: RAM内でデータがコピーされる終了位置
    
    ALIGN(4): セクションの配置アドレスを4バイトに境界に揃える
    */

    __data_org = .;
    .data_org = .;
    .data : AT(__data_org) {
        __data_start = .;
        *(.data)
        *(.data.*)
        . = ALIGN(4);
        __data_end = .;
    } > RAM

    /*
    初期化していない変数 (ゼロ初期化) を配置
    実行時にゼロクリアされる
    __bss_start: .bss領域の開始位置
    __bss_end: .bss領域の終了位置
    __end: メモリの最後の位置
    */
    .bss ALIGN(4) (NOLOAD) : {
        __bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
        __end = .;
    } > RAM
}
