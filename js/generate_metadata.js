const fs = require('fs');

let args = process.argv
if (args.length < 3) {
    console.log("Usage: node generate_metadata.js <target_dir>")
    process.exit(1)
}
let targetDir = args[args.length - 1]
let totalFrames = 349
let totalSupply = 888
let metaInfo = {
    "name": "Draup Member Pass",
    "description": "NFT pass that symbolizes the holders Draup community membership and offers exclusive community access.",
    "external_url": "https://www.draup.xyz",
    "animation_url": "https://assets.draup.xyz/member_pass/video/DRAUP_members_pass.mp4",
    "image": "https://assets.draup.xyz/member_pass/frames/DRAUP_member_frame_"
}
for (let i = 0; i <= totalSupply; i++) {
    let targetData = {
        name: metaInfo.name,
        description: metaInfo.description,
        external_url: metaInfo.external_url,
        animation_url: metaInfo.animation_url,
        image: `${metaInfo.image}${String(i % totalFrames).padStart(3, '0')}.png`
    }
    fs.writeFileSync(`${targetDir}/member_pass_${String(i).padStart(3, '0')}.json`, JSON.stringify(targetData, null, 2) + "\n" );
}