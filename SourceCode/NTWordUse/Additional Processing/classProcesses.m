/*=====================================================================================================*
 *                                                                                                     *
 *                                     NTWordUse: classProcesses.m                                     *
 *                                     ===========================                                     *
 *                                                                                                     *
 *  Created by Leonard Clark on 26/12/2021.                                                            *
 *                                                                                                     *
 *=====================================================================================================*/

#import "classProcesses.h"

@implementation classProcesses

NSMutableDictionary *initialConv, *stripAll, *transliteration, *majisculeMarkers;

- (id) init
{
    NSInteger idx, totalChars;
    NSArray *possibleCaps, *replacementMins;

    self = [super init];
    /*----------------------------------------------------------------------------------------------------------------------------------------*
     *                                                                                                                                        *
     *  What follows is the source data for the Dictionaries defined globally (above).  We will provide a brief description of each set of    *
     *    arrays, as they arrive.                                                                                                             *
     *                                                                                                                                        *
     *----------------------------------------------------------------------------------------------------------------------------------------*/
    
    /*----------------------------------------------------------------------------------------------------------------------------------------*
     *                                                                                                                                        *
     *  possibleCaps (replacement values: replacementMins)                                                                                    *
     *  ------------                                                                                                                          *
     *                                                                                                                                        *
     *  All the majiscules to be replaced by minicules for reporting purposes. These will be stored in initialConv so that the majiscule (the *
     *    key value) can easily be replaced by the equivalent miniscule (the equivalent character in replacementMins).                        *
     *                                                                                                                                        *
     *----------------------------------------------------------------------------------------------------------------------------------------*/
    
    possibleCaps = [[ NSArray alloc] initWithObjects:@"Α", @"Ἀ", @"Ἁ", @"Ἂ", @"Ἃ", @"Ἄ", @"Ἅ", @"Β", @"Γ", @"Δ", @"Ε", @"Ἐ", @"Ἑ", @"Ἒ", @"Ἓ", @"Ἔ", @"Ἕ", @"Ζ",
                    @"Η", @"Ἠ", @"Ἡ", @"Ἢ", @"Ἣ", @"Ἤ", @"Ἥ", @"Θ", @"Ι", @"Ἰ", @"Ἱ", @"Ἲ", @"Ἳ", @"Ἴ", @"Ἵ", @"Κ", @"Λ", @"Μ", @"Ν", @"Ξ", @"Ο", @"Ὀ", @"Ὁ",
                    @"Ὂ", @"Ὃ", @"Ὄ", @"Ὅ", @"Π", @"Ρ", @"Σ", @"Τ", @"Υ", @"Ὑ", @"Ὓ", @"Ὕ", @"Φ", @"Χ", @"Ψ", @"Ω", @"Ὠ", @"Ὡ", @"Ὢ", @"Ὣ", @"Ὤ", @"Ὥ", nil];
    replacementMins = [[NSArray alloc] initWithObjects:@"α", @"ἀ", @"ἁ", @"ἂ", @"ἃ", @"ἄ", @"ἅ", @"β", @"γ", @"δ", @"ε", @"ἐ", @"ἑ", @"ἒ", @"ἓ", @"ἔ", @"ἕ", @"ζ",
                       @"η", @"ἠ", @"ἡ", @"ἢ", @"ἣ", @"ἤ", @"ἥ", @"θ", @"ι", @"ἰ", @"ἱ", @"ἲ", @"ἳ", @"ἴ", @"ἵ", @"κ", @"λ", @"μ", @"ν", @"ξ", @"ο", @"ὀ", @"ὁ",
                       @"ὂ", @"ὃ", @"ὄ", @"ὅ", @"π", @"ρ", @"σ", @"τ", @"υ", @"ὑ", @"ὓ", @"ὕ", @"φ", @"χ", @"ψ", @"ω", @"ὠ", @"ὡ", @"ὢ", @"ὣ", @"ὤ", @"ὥ", nil];
    
    /*----------------------------------------------------------------------------------------------------------------------------------------*
     *                                                                                                                                        *
     *  allGkLetters (replacement values: baseGkLetters)                                                                                      *
     *  ------------                                                                                                                          *
     *                                                                                                                                        *
     *  Despite the name, this array stores all the values represented in the higher tabale in Unicode (hex 1f00 onwards).  The immediate     *
     *    comparison is with baseGkLetters.  The idea here is that a normal Greek word can be reduced to one composed only of basic           *
     *    characters (i.e. characters without breathings, accents and the like).  It also reduces majiscules to miniscules.  The purpose of   *
     *    this comparison is to enable sorting for e.g. the initial list of words - otherwise we woukd get all words starting with majiscules *
     *    before any starting with miniscules and all words of a given character with a rough breathing woul precede any word with the same   *
     *    character but with a smooth breathing.                                                                                              *
     *                                                                                                                                        *
     *----------------------------------------------------------------------------------------------------------------------------------------*/
    
    NSArray *allGkLetters = [[NSArray alloc] initWithObjects:@"ἀ", @"ἁ", @"ἂ", @"ἃ", @"ἄ", @"ἅ", @"ἆ", @"ἇ", @"Ἀ", @"Ἁ", @"Ἂ", @"Ἃ", @"Ἄ", @"Ἅ", @"Ἆ", @"Ἇ", @"ᾀ",
                          @"ᾁ", @"ᾂ", @"ᾃ", @"ᾄ", @"ᾅ", @"ᾆ", @"ᾇ", @"ᾈ", @"ᾉ", @"ᾊ", @"ᾋ", @"ᾌ", @"ᾍ", @"ᾎ", @"ᾏ", @"ᾰ", @"ᾱ", @"ᾲ", @"ᾳ", @"ᾴ", @"ᾶ",
                          @"ᾷ", @"Ᾰ", @"Ᾱ", @"Ὰ", @"Ά", @"ᾼ", @"ὰ", @"ά", @"ἐ", @"ἑ", @"ἒ", @"ἓ", @"ἔ", @"ἕ", @"Ἐ", @"Ἑ", @"Ἒ", @"Ἓ", @"Ἔ", @"Ἕ",
                          @"ὲ", @"έ", @"Ὲ", @"Έ", @"ἠ", @"ἡ", @"ἢ", @"ἣ", @"ἤ", @"ἥ", @"ἦ", @"ἧ", @"Ἠ", @"Ἡ", @"Ἢ", @"Ἣ", @"Ἤ", @"Ἥ", @"Ἦ", @"Ἧ", @"ᾐ", @"ᾑ",
                          @"ᾒ", @"ᾓ", @"ᾔ", @"ᾕ", @"ᾖ", @"ᾗ", @"ᾘ", @"ᾙ", @"ᾚ", @"ᾛ", @"ᾜ", @"ᾝ", @"ᾞ", @"ᾟ", @"ῂ", @"ῃ", @"ῄ", @"ῆ", @"ῇ", @"Ὴ", @"Ή", @"ῌ",
                          @"ὴ", @"ή", @"ἰ", @"ἱ", @"ἲ", @"ἳ", @"ἴ", @"ἵ", @"ἶ", @"ἷ", @"Ἰ", @"Ἱ", @"Ἲ", @"Ἳ", @"Ἴ", @"Ἵ", @"Ἶ", @"Ἷ", @"ῐ", @"ῑ", @"ῒ", @"ΐ",
                          @"ῖ", @"ῗ", @"Ῐ", @"Ῑ", @"Ὶ", @"Ί", @"ὶ", @"ί", @"ὀ", @"ὁ", @"ὂ", @"ὃ", @"ὄ", @"ὅ", @"Ὀ", @"Ὁ", @"Ὂ", @"Ὃ", @"Ὄ", @"Ὅ", @"ὸ", @"ό",
                          @"ὐ", @"ὑ", @"ὒ", @"ὓ", @"ὔ", @"ὕ", @"ὖ", @"ὗ", @"Ὑ", @"Ὓ", @"Ὕ", @"Ὗ", @"ῠ", @"ῡ", @"ῢ", @"ΰ", @"ῦ", @"ῧ", @"Ῠ", @"Ῡ", @"Ὺ", @"Ύ",
                          @"ὺ", @"ύ", @"ὠ", @"ὡ", @"ὢ", @"ὣ", @"ὤ", @"ὥ", @"ὦ", @"ὧ", @"Ὠ", @"Ὡ", @"Ὢ", @"Ὣ", @"Ὤ", @"Ὥ", @"Ὦ", @"Ὧ", @"ᾠ", @"ᾡ", @"ᾢ", @"ᾣ",
                          @"ᾤ", @"ᾥ", @"ᾦ", @"ᾧ", @"ᾨ", @"ᾩ", @"ᾪ", @"ᾫ", @"ᾬ", @"ᾭ", @"ᾮ", @"ᾯ", @"ῲ", @"ῳ", @"ῴ", @"ῶ", @"ῷ", @"Ὸ", @"Ό", @"Ὼ", @"Ώ", @"ῼ",
                          @"ὼ", @"ώ", @"ῤ", @"ῥ", @"Ῥ", @"Ά", @"Έ", @"Ή", @"Ί", @"Ό", @"Ύ", @"Ώ", @"ΐ", @"Α", @"Β", @"Γ", @"Δ", @"Ε", @"Ζ", @"Η", @"Θ", @"Ι",
                          @"Κ", @"Λ", @"Μ", @"Ν", @"Ξ", @"Ο", @"Π", @"Ρ", @"Σ", @"Τ", @"Υ", @"Φ", @"Χ", @"Ψ", @"Ω", @"Ϊ", @"Ϋ", @"ά", @"έ", @"ή", @"ί", @"ΰ",
                          @"α", @"β", @"γ", @"δ", @"ε", @"ζ", @"η", @"θ", @"ι", @"κ", @"λ", @"μ", @"ν", @"ξ", @"ο", @"π", @"ρ", @"ς", @"σ", @"τ", @"υ", @"φ",
                          @"χ", @"ψ", @"ω", @"ϊ", @"ϋ", @"ό", @"ύ", @"ώ", nil];
    NSArray *baseGkLetters = [[NSArray alloc] initWithObjects:@"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α",
                              @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α",
                              @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"α", @"ε", @"ε", @"ε", @"ε", @"ε", @"ε", @"ε", @"ε", @"ε", @"ε", @"ε", @"ε",
                              @"ε", @"ε", @"ε", @"ε", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η",
                              @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η", @"η",
                              @"η", @"η", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι",
                              @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ι", @"ο", @"ο", @"ο", @"ο", @"ο", @"ο", @"ο", @"ο", @"ο", @"ο", @"ο", @"ο", @"ο", @"ο",
                              @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ", @"υ",
                              @"υ", @"υ", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω",
                              @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ω", @"ο", @"ο", @"ω", @"ω", @"ω",
                              @"ω", @"ω", @"ρ", @"ρ", @"ρ", @"α", @"ε", @"η", @"ι", @"ο", @"υ", @"ω", @"ι", @"α", @"β", @"γ", @"δ", @"ε", @"ζ", @"η", @"θ", @"ι",
                              @"κ", @"λ", @"μ", @"ν", @"ξ", @"ο", @"π", @"ρ", @"σ", @"τ", @"υ", @"φ", @"Χ", @"Ψ", @"ω", @"ι", @"υ", @"α", @"ε", @"η", @"ι", @"υ",
                              @"α", @"β", @"γ", @"δ", @"ε", @"ζ", @"η", @"θ", @"ι", @"κ", @"λ", @"μ", @"ν", @"ξ", @"ο", @"π", @"ρ", @"ς", @"σ", @"τ", @"υ", @"φ",
                              @"χ", @"ψ", @"ω", @"ι", @"υ", @"ο", @"υ", @"ω", nil];
    
    /*----------------------------------------------------------------------------------------------------------------------------------------*
     *                                                                                                                                        *
     *  baseLetters (replacement values: baseReplacements)                                                                                    *
     *  ------------                                                                                                                          *
     *                                                                                                                                        *
     *  This pair of arrays allow us to recreate CATT's transliteration of Greek.                                                             *
     *                                                                                                                                        *
     *----------------------------------------------------------------------------------------------------------------------------------------*/
    
    NSArray *baseLetters = [[NSArray alloc] initWithObjects:@"Ά", @"Έ", @"Ή", @"Ί", @"Ό", @"Ύ", @"Ώ", @"ΐ", @"Α", @"Β", @"Γ", @"Δ", @"Ε", @"Ζ", @"Η", @"Θ", @"Ι", @"Κ", @"Λ", @"Μ", @"Ν", @"Ξ", @"Ο", @"Π", @"Ρ", @"Σ", @"Τ", @"Υ", @"Φ", @"Χ", @"Ψ", @"Ω", @"Ϊ", @"Ϋ", @"ά", @"έ", @"ή", @"ί", @"ΰ", @"α", @"β", @"γ", @"δ", @"ε", @"ζ", @"η", @"θ", @"ι", @"κ", @"λ", @"μ", @"ν", @"ξ", @"ο", @"π", @"ρ", @"ς", @"σ", @"τ", @"υ", @"φ", @"χ", @"ψ", @"ω", @"ϊ", @"ϋ", @"ό", @"ύ", @"ώ",
                            @"(", @")", @"ʹ", @"-", @"̈̈", @"\u0308", @"\u03dc", @"\u03dd", nil];
    NSArray *baseReplacements = [[NSArray alloc] initWithObjects:@"A/", @"E/", @"H/", @"I/", @"O/", @"U/", @"W/", @"i/:", @"A", @"B", @"G", @"D", @"E", @"Z", @"H", @"Q", @"I", @"K", @"L", @"M", @"N", @"C", @"O", @"P", @"R", @"S", @"T", @"U", @"F", @"X", @"Y", @"W", @"I:", @"U:", @"a/", @"e/", @"h/", @"i/", @"u/:", @"a", @"b", @"g", @"d", @"e", @"z", @"h", @"q", @"i", @"k", @"l", @"m", @"n", @"c", @"o", @"p", @"r", @"j", @"s", @"t", @"u", @"f", @"x", @"y", @"w", @"i:", @"u:", @"o/", @"u/", @"w/",
                                 @"[", @"]", @"'", @"_", @":", @":", @"V", @"v", nil];
    
    /*----------------------------------------------------------------------------------------------------------------------------------------*
     *                                                                                                                                        *
     *  mainGkLetters (replacement values: allReplacement)                                                                                    *
     *  ------------                                                                                                                          *
     *                                                                                                                                        *
     *  This pair of arrays continues the recreation of CATT's transliteration of Greek.                                                      *
     *                                                                                                                                        *
     *----------------------------------------------------------------------------------------------------------------------------------------*/
    
    NSArray *mainGkLetters = [[NSArray alloc] initWithObjects:
                             @"ἀ", @"ἁ", @"ἂ", @"ἃ", @"ἄ", @"ἅ", @"ἆ", @"ἇ", @"Ἀ", @"Ἁ", @"Ἂ", @"Ἃ", @"Ἄ", @"Ἅ", @"Ἆ", @"Ἇ",
                             @"ἐ", @"ἑ", @"ἒ", @"ἓ", @"ἔ", @"ἕ", @"Ἐ", @"Ἑ", @"Ἒ", @"Ἓ", @"Ἔ", @"Ἕ",
                             @"ἠ", @"ἡ", @"ἢ", @"ἣ", @"ἤ", @"ἥ", @"ἦ", @"ἧ", @"Ἠ", @"Ἡ", @"Ἢ", @"Ἣ", @"Ἤ", @"Ἥ", @"Ἦ", @"Ἧ",
                             @"ἰ", @"ἱ", @"ἲ", @"ἳ", @"ἴ", @"ἵ", @"ἶ", @"ἷ", @"Ἰ", @"Ἱ", @"Ἲ", @"Ἳ", @"Ἴ", @"Ἵ", @"Ἶ", @"Ἷ",
                             @"ὀ", @"ὁ", @"ὂ", @"ὃ", @"ὄ", @"ὅ", @"Ὀ", @"Ὁ", @"Ὂ", @"Ὃ", @"Ὄ", @"Ὅ",
                             @"ὐ", @"ὑ", @"ὒ", @"ὓ", @"ὔ", @"ὕ", @"ὖ", @"ὗ", @"Ὑ", @"Ὓ", @"Ὕ", @"Ὗ",
                             @"ὠ", @"ὡ", @"ὢ", @"ὣ", @"ὤ", @"ὥ", @"ὦ", @"ὧ", @"Ὠ", @"Ὡ", @"Ὢ", @"Ὣ", @"Ὤ", @"Ὥ", @"Ὦ", @"Ὧ",
                             @"ὰ", @"\u1f71", @"ὲ", @"\u1f73", @"ὴ", @"\u1f75", @"ὶ", @"\u1f77", @"ὸ", @"\u1f79", @"ὺ", @"\u1f7b", @"ὼ", @"\u1f7d",
                             @"ᾀ", @"ᾁ", @"ᾂ", @"ᾃ", @"ᾄ", @"ᾅ", @"ᾆ", @"ᾇ", @"ᾈ", @"ᾉ", @"ᾊ", @"ᾋ", @"ᾌ", @"ᾍ", @"ᾎ", @"ᾏ",
                             @"ᾐ", @"ᾑ", @"ᾒ", @"ᾓ", @"ᾔ", @"ᾕ", @"ᾖ", @"ᾗ", @"ᾘ", @"ᾙ", @"ᾚ", @"ᾛ", @"ᾜ", @"ᾝ", @"ᾞ", @"ᾟ",
                             @"ᾠ", @"ᾡ", @"ᾢ", @"ᾣ", @"ᾤ", @"ᾥ", @"ᾦ", @"ᾧ", @"ᾨ", @"ᾩ", @"ᾪ", @"ᾫ", @"ᾬ", @"ᾭ", @"ᾮ", @"ᾯ",
                             @"ᾰ", @"ᾱ", @"ᾲ", @"ᾳ", @"ᾴ", @"ᾶ", @"ᾷ", @"Ᾰ", @"Ᾱ", @"Ὰ", @"\u1fbb", @"ᾼ",
                             @"ῂ", @"ῃ", @"ῄ", @"ῆ", @"ῇ", @"Ὲ", @"\u1fc9", @"Ὴ", @"\u1fcb", @"ῌ",
                             @"ῐ", @"ῑ", @"ῒ", @"\u1fd3", @"ῖ", @"ῗ", @"Ῐ", @"Ῑ", @"Ὶ", @"\u1fdb",
                             @"ῠ", @"ῡ", @"ῢ", @"\u1fe3", @"ῤ", @"ῥ", @"ῦ", @"ῧ", @"Ῠ", @"Ῡ", @"Ὺ", @"\u1feb", @"Ῥ",
                             @"ῲ", @"ῳ", @"ῴ", @"ῶ", @"ῷ", @"Ὸ", @"\u1ff9", @"Ὼ", @"\u1ffb", @"ῼ", nil];
    NSArray *allReplacement = [[NSArray alloc] initWithObjects:@"a)", @"a(", @"a)\\", @"a(\\", @"a)/", @"a(/", @"a)=", @"a(=", @"A)", @"A(", @"A)\\", @"A(\\", @"A)/", @"A(/", @"A)=", @"A(=",
                               @"e)", @"e(", @"e)\\", @"e(\\", @"e)/", @"e(/", @"E)", @"E(", @"E)\\", @"E(\\", @"E)/", @"E(/",
                               @"h)", @"h(", @"h)\\", @"h(\\", @"h)/", @"h(/", @"h)=", @"h(=", @"H)", @"H(", @"H)\\", @"H(\\", @"H)/", @"H(/", @"H)=", @"H(=",
                               @"i)", @"i(", @"i)\\", @"i(\\", @"i)/", @"i(/", @"i)=", @"i(=", @"I)", @"I(", @"I)\\", @"I(\\", @"I)/", @"I(/", @"I)=", @"I(=",
                               @"o)", @"o(", @"o)\\", @"o(\\", @"o)/", @"o(/", @"O)", @"O(", @"O)\\", @"O(\\", @"O)/", @"O(/",
                               @"u)", @"u(", @"u)\\", @"u(\\", @"u)/", @"u(/", @"u)=", @"u(=", @"U(", @"U(\\", @"U(/", @"U(=",
                               @"w)", @"w(", @"w)\\", @"w(\\", @"w)/", @"w(/", @"w)=", @"w(=", @"W)", @"W(", @"W)\\", @"W(\\", @"W)/", @"W(/", @"W)=", @"W(=",
                               @"a\\", @"a/", @"e\\", @"e/", @"h\\", @"h/", @"i\\", @"i/", @"o\\", @"o/", @"u\\", @"u/", @"w\\", @"w/",
                               @"a)|", @"a(|", @"a)\\|", @"a(\\|", @"a)/|", @"a(/|", @"a)=|", @"a(=|", @"A)|", @"A(|", @"A)\\|", @"A(\\|", @"A)/|", @"A(/|", @"A)=|", @"A(=|",
                               @"h)|", @"h(|", @"h)\\|", @"h(\\|", @"h)/|", @"h(/|", @"h)=|", @"h(=|", @"H)|", @"H(|", @"H)\\|", @"H(\\|", @"H)/|", @"H(/|", @"H)=|", @"H(=|",
                               @"w)|", @"w(|", @"w)\\|", @"w(\\|", @"w)/|", @"w(/|", @"w)=|", @"w(=|", @"W)|", @"W(|", @"W)\\|", @"W(\\|", @"W)/|", @"W(/|", @"W)=|", @"W(=|",
                               @"a~", @"a-", @"a\\|", @"a|", @"a/|", @"a=", @"a=|", @"A~", @"A-", @"A\\", @"A/", @"A|",
                               @"h\\|", @"h|", @"h/|", @"h=", @"h=|", @"E\\", @"E-", @"H\\", @"H/", @"H|",
                               @"i~", @"i-", @"i\\:", @"i/:", @"i=", @"i=:", @"I~", @"I-", @"I\\", @"I/",
                               @"u~", @"u-", @"u\\:", @"u/:", @"r)", @"r(", @"u=", @"u=:", @"U~", @"U-", @"U\\", @"U/", @"R(",
                               @"w\\|", @"w|", @"w/|", @"w=", @"w=|", @"O\\", @"O/", @"W\\", @"W/", @"W|", nil];
    
    /*----------------------------------------------------------------------------------------------------------------------------------------*
     *                                                                                                                                        *
     *  baseGkMajMarkers                                                                                                                      *
     *  ----------------                                                                                                                      *
     *                                                                                                                                        *
     *  This is actually a replacement array.  It depends on the initial array, baseLetters.  If a baseLetter character is a majiscule, this  *
     *    array will hold the value 1; if a miniscule, it will hold the value 0.  This will allow us to replace majiscules in words where     *
     *    they only have a leading majiscule because they start a sentence (or some similar reason).                                          *
     *                                                                                                                                        *
     *----------------------------------------------------------------------------------------------------------------------------------------*/
    
    NSArray *baseGkMajMarkers = [[NSArray alloc] initWithObjects:
                                 @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"0", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1",
                                 @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0",
                                 @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0",
                            @"(", @")", @"ʹ", @"-", @"̈̈", @"\u0308", @"\u03dc", @"\u03dd", nil];
    
    /*----------------------------------------------------------------------------------------------------------------------------------------*
     *                                                                                                                                        *
     *  mainGkMajMarkers                                                                                                                      *
     *  ----------------                                                                                                                      *
     *                                                                                                                                        *
     *  This functions in the same way as baseGkMajMarkers but applies to the initial array, mainGkLetters                                    *
     *                                                                                                                                        *
     *----------------------------------------------------------------------------------------------------------------------------------------*/
    
   NSArray *mainGkMajMarkers = [[NSArray alloc] initWithObjects:
                             @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1",
                             @"0", @"0", @"0", @"0", @"0", @"1", @"1", @"1", @"1", @"1", nil];

    totalChars = [possibleCaps count];
    /*-----------------------------------------------------------------------------*
     *  initialConv:                                                               *
     *  -----------                                                                *
     *  Dictionary providing lower-case equivalents of upper-case characters       *
     *-----------------------------------------------------------------------------*/
    initialConv = [[NSMutableDictionary alloc] init];
    for (idx = 0; idx < totalChars; idx++)
    {
        [initialConv setValue:[replacementMins objectAtIndex:idx] forKey:[possibleCaps objectAtIndex:idx]];
    }
    totalChars = [allGkLetters count];
    stripAll = [[NSMutableDictionary alloc] init];
    for (idx = 0; idx < totalChars; idx++)
    {
        [stripAll setValue:[baseGkLetters objectAtIndex:idx] forKey:[allGkLetters objectAtIndex:idx]];
    }
    transliteration = [[NSMutableDictionary alloc] init];
    totalChars = [baseLetters count];
    for( idx = 0; idx < totalChars; idx++)
    {
        [transliteration setValue:[baseReplacements objectAtIndex:idx] forKey:[baseLetters objectAtIndex:idx]];
    }
    totalChars = [mainGkLetters count];
    for( idx = 0; idx < totalChars; idx++)
    {
        [transliteration setValue:[allReplacement objectAtIndex:idx] forKey:[mainGkLetters objectAtIndex:idx]];
    }
    majisculeMarkers = [[NSMutableDictionary alloc] init];
    totalChars = [baseGkMajMarkers count];
    for( idx = 0; idx < totalChars; idx++) [majisculeMarkers setValue:baseGkMajMarkers[idx] forKey:baseLetters[idx]];
    totalChars = [mainGkMajMarkers count];
    for( idx = 0; idx < totalChars; idx++) [majisculeMarkers setValue:mainGkLetters[idx] forKey:mainGkMajMarkers[idx]];
    return self;
}

- (NSInteger) getParseInfo: (NSString *) inParseInfo
{
    /*==================================================*
     *                                                  *
     *  1 = "Noun",                                     *
     *  2 = "Verb",                                     *
     *  3 = "Adjective",                                *
     *  4 = "Adverb",                                   *
     *  5 = "Preposition",                              *
     *  6 = "Article",                                  *
     *  8 = "Definite Pronoun",                         *
     *  9 = "Indefinite Pronoun",                       *
     * 10 = "Personal Pronoun",                         *
     * 11 = "Relative Pronoun",                         *
     * 12 = "Interjection",                             *
     * 13 = "Exclamation"                               *
     *                                                  *
     *==================================================*/

    int parseCode = 0;

    switch ( [inParseInfo characterAtIndex:0])
    {
        case '1':
            if ( [inParseInfo characterAtIndex:5] == 'S')
            {
                parseCode = 1;
            }
            else
            {
                parseCode = 4;
            }
            break;
        case '2':
            if ( [inParseInfo characterAtIndex:5] == 'S')
            {
                parseCode = 2;
            }
            else
            {
                parseCode = 5;
            }
            break;
        case '3':
            if ( [inParseInfo characterAtIndex:5] == 'S')
            {
                parseCode = 3;
            }
            else
            {
                parseCode = 6;
            }
            break;
        case '-':
            if ( [inParseInfo characterAtIndex:5] == 'S')
            {
                parseCode = 7;
            }
            if ( [inParseInfo characterAtIndex:5] == 'P')
            {
                parseCode = 8;
            }
            break;
    }
    switch ( [inParseInfo characterAtIndex:4])
    {
        case 'N': parseCode += 10000; break;    // Nominative
        case 'V': parseCode += 20000; break;    // Vocative
        case 'A': parseCode += 30000; break;    // Accusative
        case 'G': parseCode += 40000; break;    // Genitive
        case 'D': parseCode += 50000; break;    // Dative
        default: break;
    }
    switch ( [inParseInfo characterAtIndex:6])
    {
        case 'M': parseCode += 100000; break;    // Masculine
        case 'N': parseCode += 200000; break;    // Neuter
        case 'F': parseCode += 300000; break;    // Feminine
        default: break;
    }
    switch ( [inParseInfo characterAtIndex:1])
    {
        case 'P': parseCode += 10; break;    // Present
        case 'I': parseCode += 20; break;    // Imperfect
        case 'A': parseCode += 30; break;    // Aorist
        case 'X': parseCode += 40; break;    // Perfect
        case 'Y': parseCode += 50; break;    // Pluperfect
        case 'F': parseCode += 60; break;    // Future
        default: break;
    }
    switch ( [inParseInfo characterAtIndex:3])
    {
        case 'I': parseCode += 100; break;    // Indicative
        case 'D': parseCode += 200; break;    // Imperative
        case 'S': parseCode += 300; break;    // Subjunctive
        case 'O': parseCode += 400; break;    // Optative
        case 'N': parseCode += 500; break;    // Infinitive
        case 'P': parseCode += 600; break;    // Participle
        default: break;
    }
    switch ( [inParseInfo characterAtIndex:2])
    {
        case 'A': parseCode += 1000; break;    // Active
        case 'M': parseCode += 2000; break;    // Middle
        case 'P': parseCode += 3000; break;    // Passive
        default: break;
    }
    switch ( [inParseInfo characterAtIndex:7])
    {
        case 'C': parseCode += 1000000; break;    // Comparative
        case 'S': parseCode += 2000000; break;    // Superlative
        default: break;
    }
    return parseCode;
}

- (NSInteger) getLxxParseInfo: (NSString *) inParseInfo withCode: (NSInteger) categoryCode
{
    /*==================================================*
     *                                                  *
     *  Possible Category Code values:                  *
     *                                                  *
     *  1 = "Noun",                                     *
     *  2 = "Verb",                                     *
     *  3 = "Adjective",                                *
     *  4 = "Adverb",                                   *
     *  5 = "Preposition",                              *
     *  6 = "Article",                                  *
     *  7 = "Demonstrative Pronoun",                    *
     *  8 = "Indefinite Pronoun",                       *
     *  9 = "Personal Pronoun",                         *
     * 10 = "Relative Pronoun",                         *
     * 11 = "Particle",                                 *
     * 12 = "Conjunction"                               *
     * 13 = "Interjection",                             *
     * Not used because omitted                         *
     * 14 = "ὅστις",                                    *
     * 15 = "Indeclinable Number"                       *
     *                                                  *
     *==================================================*/

    int parseCode = 0;

    switch (categoryCode)
    {
        case 0: // Nouns
        case 2: // Adjectives
        case 5: // Articles
        case 6: // Demonstrative Pronouns
        case 7: // Indefinite Pronoun
        case 8: // Personal Pronoun
        case 9: // Relative Pronoun
        case 10: // ὅστις
            if ( [inParseInfo length] > 0)
            {
                switch ( [inParseInfo characterAtIndex:0])
                {
                    case 'N': parseCode += 10000; break;    // Nominative
                    case 'V': parseCode += 20000; break;    // Vocative
                    case 'A': parseCode += 30000; break;    // Accusative
                    case 'G': parseCode += 40000; break;    // Genitive
                    case 'D': parseCode += 50000; break;    // Dative
                    default: break;
                }
            }
            if ([inParseInfo length] > 1)
            {
                switch ([inParseInfo characterAtIndex:1])
                {
                    case 'S': parseCode += 7; break;
                    case 'D': parseCode += 8; break;
                    case 'P': parseCode += 8; break;
                    default: break;
                }
            }
            if ([inParseInfo length] > 2)
            {
                switch ([inParseInfo characterAtIndex:2])
                {
                    case 'M': parseCode += 100000; break;    // Masculine
                    case 'N': parseCode += 200000; break;    // Neuter
                    case 'F': parseCode += 300000; break;    // Feminine
                    default: break;
                }
            }
            if (categoryCode == 2)
            {
                if ([inParseInfo length] > 3)
                {
                    if ([inParseInfo characterAtIndex:3] == 'C') parseCode += 1000000;     // Comparative
                    if ([inParseInfo characterAtIndex:3] == 'S') parseCode += 2000000;    // Superlative
                }
            }
            break;
        case 1: // Verbs
            switch ([inParseInfo characterAtIndex:0])
            {
                case 'P': parseCode += 10; break;    // Present
                case 'I': parseCode += 20; break;    // Imperfect
                case 'A': parseCode += 30; break;    // Aorist
                case 'X': parseCode += 40; break;    // Perfect
                case 'Y': parseCode += 50; break;    // Pluperfect
                case 'F': parseCode += 60; break;    // Future
                default: break;
            }
            switch ([inParseInfo characterAtIndex:1])
            {
                case 'A': parseCode += 1000; break;    // Active
                case 'M': parseCode += 2000; break;    // Middle
                case 'P': parseCode += 3000; break;    // Passive
                default: break;
            }
            switch ([inParseInfo characterAtIndex:2])
            {
                case 'I': parseCode += 100; break;    // Indicative
                case 'D': parseCode += 200; break;    // Imperative
                case 'S': parseCode += 300; break;    // Subjunctive
                case 'O': parseCode += 400; break;    // Optative
                case 'N': parseCode += 500; break;    // Infinitive
                case 'P': parseCode += 600; break;    // Participle
                default: break;
            }
            if ([inParseInfo characterAtIndex:2] == 'P')
            {
                switch ([inParseInfo characterAtIndex:3])
                {
                    case 'N': parseCode += 10000; break;    // Nominative
                    case 'V': parseCode += 20000; break;    // Vocative
                    case 'A': parseCode += 30000; break;    // Accusative
                    case 'G': parseCode += 40000; break;    // Genitive
                    case 'D': parseCode += 50000; break;    // Dative
                    default: break;
                }
                switch ([inParseInfo characterAtIndex:4])
                {
                    case 'S': parseCode += 7; break;
                    case 'D': parseCode += 8; break;
                    case 'P': parseCode += 8; break;
                    default: break;
                }
                switch ([inParseInfo characterAtIndex:5])
                {
                    case 'M': parseCode += 100000; break;    // Masculine
                    case 'N': parseCode += 200000; break;    // Neuter
                    case 'F': parseCode += 300000; break;    // Feminine
                    default: break;
                }
            }
            else
            {
                if ([inParseInfo length] > 3)
                {
                    switch ([inParseInfo characterAtIndex:3])
                    {
                        case '1':
                            if ([inParseInfo characterAtIndex:4] == 'S')
                            {
                                parseCode += 1;
                            }
                            else
                            {
                                parseCode += 4;
                            }
                            break;
                        case '2':
                            if ([inParseInfo characterAtIndex:4] == 'S')
                            {
                                parseCode += 2;
                            }
                            else
                            {
                                parseCode += 5;
                            }
                            break;
                        case '3':
                            if ([inParseInfo characterAtIndex:4] == 'S')
                            {
                                parseCode += 3;
                            }
                            else
                            {
                                parseCode += 6;
                            }
                            break;
                    }
                }
            }
            break;
        default: break;
    }
    return parseCode;
}

- (NSString *) cleanTextWord: (NSString *) givenWord withInitialChatacter: (NSString *) rootInitial
{
    /*=============================================================================*
     *                                                                             *
     *                               cleanTextWord                                 *
     *                               =============                                 *
     *                                                                             *
     *  Remove capital letters from words that start a sentence or are capitalised *
     *  for other reasons, but checking first that they don't legitimately start   *
     *  with a capital (i.e. they are not someone's name or a place name).         *
     *                                                                             *
     *=============================================================================*/
    
    NSInteger marker;
    NSString *firstLetter, *newLetter, *comparison;
//    NSString *newWord;

    // Get the first letter of the supplied word
    if( [givenWord length] == 1) firstLetter = [[NSString alloc] initWithString:givenWord];
    else firstLetter = [[NSString alloc] initWithString:[givenWord substringToIndex:1]];
    if( [rootInitial length] == 1) comparison = [[NSString alloc] initWithString:rootInitial];
    else comparison = [[NSString alloc] initWithString:[rootInitial substringToIndex:1]];
    // Two conditions:
    // a) the first letter is found in initialConv (i.e. it _is_ a capital)
    // b) the first letter of the word's root is _not_ a capital (i.e. is not a person or place)
/*    if (( [initialConv doesContain:firstLetter]) && (! [initialConv doesContain:rootInitial]))
    {
        newLetter = [[NSString alloc] initWithString: [initialConv objectForKey:firstLetter]];
        newWord = [[NSString alloc] initWithFormat:@"%@%@", newLetter, [givenWord substringFromIndex:1]];
    }
    else
    {
        newWord = [[NSString alloc] initWithString: givenWord];
    } */
    marker = [[majisculeMarkers objectForKey:comparison] integerValue];
    if( marker == 1) return  givenWord;  // If the root starts with a majiscule, accept the given word, whatever the first letter
    marker = [[majisculeMarkers objectForKey:firstLetter] integerValue];
    if( marker == 0) return givenWord;  // Both are lower case - no problem
    newLetter = [[NSString alloc] initWithString: [initialConv objectForKey:firstLetter]];
    return [[NSString alloc] initWithFormat:@"%@%@", newLetter, [givenWord substringFromIndex:1]];
}

- (NSString *) nakedWord: (NSString *) sourceWord
{
    /*=============================================================================*
     *                                                                             *
     *                               nakedWord                                     *
     *                               =========                                     *
     *                                                                             *
     *  Returns a string with *all* furniture removed (i.e. breathings, accents,   *
     *  diaereses and iota subscripts).  This is to allow simple comparisons with  *
     *  text entered using the virtual keyboard.                                   *
     *                                                                             *
     *=============================================================================*/
    
    NSInteger idx, wordLength;
    NSString *givenChar, *replacedChar;
    NSMutableString *returnedString;
    
    returnedString = [[NSMutableString alloc] initWithString:@""];
    wordLength = [sourceWord length];
    for( idx = 0; idx < wordLength; idx++)
    {
        givenChar = [sourceWord substringWithRange:(NSMakeRange(idx, 1))];
        replacedChar = [stripAll objectForKey:givenChar];
        if( replacedChar == nil) [returnedString appendString:givenChar];
        else [returnedString appendString:replacedChar];
    }
    return returnedString;
}

- (NSInteger) getReferenceCode: (NSInteger) bookNo andChapter: (NSInteger) chapNo andVerse: (NSInteger) verseNo
{
    NSInteger refCode;

    refCode = bookNo * 1000000 + chapNo * 1000 + verseNo;
    return refCode;
}

- (NSString *) getLowerCaseEquivalent: (NSString *) sourceCharacter
{
    NSString *singleSource, *replacement;
    
    if( [sourceCharacter length] == 0) return @"";
    if( [sourceCharacter length] > 1) singleSource = [[NSString alloc] initWithString:[sourceCharacter substringToIndex:1]];
    else singleSource = [[NSString alloc] initWithString:sourceCharacter];
    if( [initialConv objectForKey:singleSource] == nil) replacement = [[NSString alloc] initWithString:sourceCharacter];
    else replacement = [[NSString alloc] initWithString:[initialConv objectForKey:singleSource]];
    return  replacement;
}

- (NSArray *) simpleGkSort: (NSArray *) sourceArray
{
    /*====================================================================================*
     *                                                                                    *
     *                                 simpleGkSort                                       *
     *                                 ============                                       *
     *                                                                                    *
     *  Purpose:                                                                          *
     *  =======                                                                           *
     *                                                                                    *
     *  To provide a sorted array of words that ignore breathings, accents etc.           *
     *                                                                                    *
     *====================================================================================*/
    
    NSInteger idx, wordLength;
    NSString *arrayContent, *baseLetter, *originalWord, *currentCharacter;
    NSMutableString *clearContent;
    NSArray *sortedBase;
    NSMutableArray *nakedArray, *sortedArray;
    NSMutableDictionary *clearAndOriginal;
    
    nakedArray = [[NSMutableArray alloc] init];
    clearAndOriginal = [[NSMutableDictionary alloc] init];
    for( arrayContent in sourceArray)
    {
        // Step through the source array, word by word
        clearContent = [[NSMutableString alloc] initWithString:@""];
        wordLength = [arrayContent length];
        // Create a "base" copy of the current word (no breathings, accents, etc
        for( idx = 0; idx < wordLength; idx++ )
        {
            currentCharacter = [stripAll objectForKey:[arrayContent substringWithRange:(NSMakeRange(idx, 1))]];
            if( currentCharacter == nil) continue;
            baseLetter = [[NSString alloc] initWithString:currentCharacter];
            [clearContent appendString:baseLetter];
        }
        // Create an array of the resulting string *in the same order as the source array*
        [nakedArray addObject:[[NSString alloc]initWithString:[clearContent copy]]];
        // Also, create a dictionary that links the "base" string to its original
        [clearAndOriginal setValue:arrayContent forKey:[[NSString alloc]initWithString:[clearContent copy]]];
    }
    // So, now we have an unsorted "base" array and a means of linking it to the original words
    // Create a sorted version of the "base" array
    sortedBase = [[NSArray alloc] initWithArray:[nakedArray sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)]];
    // Now create a new array from the "base" array in the new, sorted order but with original words
    sortedArray = [[NSMutableArray alloc] init];
    for( arrayContent in sortedBase)
    {
        originalWord = [[NSString alloc] initWithString:[clearAndOriginal objectForKey:arrayContent]];
        [sortedArray addObject:originalWord];
    }
    return [sortedArray copy];
}

- (NSString *) transliterateText: (NSString *) sourceString
{
    NSInteger idx, stringLength;
    NSString *currentChar, *replacementChar;
    NSMutableString *workArea;
    
    workArea = [[NSMutableString alloc] initWithString:@""];
    stringLength = [sourceString length];
    for( idx = 0; idx < stringLength; idx++)
    {
        currentChar = [[NSString alloc] initWithString:[sourceString substringWithRange:(NSMakeRange(idx, 1))]];
        replacementChar = [[NSString alloc] initWithString:[transliteration objectForKey:currentChar]];
        if( replacementChar == nil) replacementChar = currentChar;
        [workArea appendString:replacementChar];
    }
    return [workArea copy];
}

@end
