pcall(require, "printr")
package.path = "../?/init.lua;"..package.path
require("cue")

-- from my music folder...
sheet = [[﻿REM GENRE Game
REM DATE 2010
REM DISCID 49062507
REM COMMENT "ExactAudioCopy v0.99pb5"
PERFORMER "イオシス"
TITLE "東方アゲハ"
FILE "東方アゲハ.tta" WAVE
  TRACK 01 AUDIO
    TITLE "Letty Whiterock You!"
    PERFORMER "miko"
    INDEX 01 00:00:00
  TRACK 02 AUDIO
    TITLE "キャプテン・ムラサのケツアンカー"
    PERFORMER "山本 椛"
    INDEX 01 02:20:49
  TRACK 03 AUDIO
    TITLE "断罪ヤマザナドゥ！"
    PERFORMER "岩杉 夏"
    INDEX 01 05:44:01
  TRACK 04 AUDIO
    TITLE "てんこの恋愛下克上！エクスクラクラ☆ラメーション！"
    PERFORMER "miko"
    INDEX 01 09:39:39
  TRACK 05 AUDIO
    TITLE "水橋ジェラシックパーク"
    PERFORMER "miko"
    INDEX 01 12:48:26
  TRACK 06 AUDIO
    TITLE "ひなりんのヤクい関係"
    PERFORMER "一ノ瀬 月琉"
    INDEX 01 18:41:50
  TRACK 07 AUDIO
    TITLE "キャプテン・ARMのケツアンカー"
    PERFORMER "ARM"
    INDEX 01 22:53:18]]

decoded = cue.decode(sheet)

if printr then
  printr(decoded)
else
  print("if you had a printr module, you'd see a pretty table right here")
end

print""

print("title of track 3: "..decoded.tracks[3].title)
print("start-index of track 7: "..decoded.tracks[7].indices[1])