import python
import semmle.python.Concepts
import semmle.python.dataflow.new.DataFlow
import semmle.python.filters.Tests

// TODO
from Cryptography::PublicKey::KeyGeneration keyGen, int keySize, DataFlow::Node origin
where
  keySize = keyGen.getKeySizeWithOrigin(origin) and
  keySize < keyGen.minimumSecureKeySize() and
  not origin.getScope().getScope*() instanceof TestScope
select keyGen,
  "Creation of an " + keyGen.getName() + " key uses $@ bits, which is below " +
    keyGen.minimumSecureKeySize() + " and considered breakable.", origin, keySize.toString()
