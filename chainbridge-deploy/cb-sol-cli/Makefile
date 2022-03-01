SOL_URL=http://git.everylink.ai/blockchain/chainbridge-solidity.git

fetch-contracts:
	@echo " > \033[32mFetching chainbridge-solidity contracts... \033[0m "
	git clone ${SOL_URL} chainbridge-solidity && cd chainbridge-solidity

compile:
	cd chainbridge-solidity && npm install && npx truffle compile

install: fetch-contracts compile
	@echo " > \033[32mInstalling cb-sol-cli... \033[0m "
	npm link .

clean:
	rm -rf chainbridge-solidity/
