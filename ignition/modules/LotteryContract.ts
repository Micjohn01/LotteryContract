import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const MicjohnModule = buildModule("MicjohnModule", (m) => {

    const lottery = m.contract("LotteryContract");

    return { lottery };
});

export default MicjohnModule;