#ifndef SYSLIB_H
#define SYSLIB_H

/*
 * 共通ライブラリ関数定義
 */

/* 
 * 32bitレジスタからの入力
 * volatile unsigned int型の値を読み出す
 */
static inline UW in_w(UW adr)
{
    return *(_UW*)adr;
}

/*
 * 32bitレジスタへの出力
 * 指定したアドレスadrにdataを書き込む
 */
static inline void out_w(UW adr, UW data)
{
    *(_UW*)adr = data;
}

/* 32bitレジスタへの出力 (ビットクリア) */
#define OP_CLR      0x3000
static inline void clr_w(UW adr, UW data)
{
    *(_UW*)(adr + OP_CLR) = data;
}

/* 32bitレジスタへの出力 (ビットセット) */
#define OP_SET      0x2000
static inline void set_w(UW adr, UW data)
{
    *(_UW*)(adr + OP_SET) = data;
}

/* 32bitレジスタへの出力 (ビット排他的論理和) */
#define OP_XOR      0x1000
static inline void xset_w(UW adr, UW data)
{
    *(_UW*)(adr + OP_XOR) = data;
}

/*
 * PRIMASKレジスタ制御インライン関数
 * PRIMASKレジスタは割り込みの有効/無効を制御するためのレジスタ
 */

/*
 * pmに指定した値をPRIMASKレジスタに設定する
 * アセンブリ命令MSRを使用してPRIMASKを直接設定する
 * pm = 1ですべての割り込みを無効化する. pm = 0で割り込みを許可する
 */
static inline void set_primask( INT pm )
{
    __asm__ volatile("msr primask, %0":: "r"(pm));
}

/*
 * 現在のPRIMASKレジスタの値を取得する
 * アセンブリ命令MRSを使用してPRIMASKを直接読み取っている
 */
static inline UW get_primask( void )
{
    UW pm;
    __asm__ volatile("mrs %0, primask": "=r"(pm));
    return pm;
}

/*
 * 割り込み禁止マクロ
 * 現在のPRIMASKの値をintstsに保存した後, set_primask(1)ですべての割り込みを禁止する
 */
#define DI(intsts)      (intsts=get_primask(), set_primask(1))

/*
 * 割り込み許可マクロ
 * DIで保存したintstsの値をset_primaskに渡し, PRIMASKを元の状態に戻す
 */
#define EI(intsts)      (set_primask(intsts))

#endif /* SYSLIB_H */