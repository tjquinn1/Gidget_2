import transit from 'transit-js';
import Immutable from 'immutable';

const createReader = function createReader() {
  return transit.reader('json', {
    mapBuilder: {
      init: () => Immutable.Map().asMutable(),
      add: (m, k, v) => {
        if (transit.isKeyword(k)) {
          return m.set(k.toString(), v);
        }
        return m.set(k, v);
      },
      finalize: (m) => m.asImmutable(),
    },
    arrayBuilder: {
      init: () => Immutable.List().asMutable(),
      add: (m, v) => m.push(v),
      finalize: (m) => m.asImmutable(),
    },
    handlers: {
      ':': (rep) => `:${rep}`,
      list: (rep) => Immutable.List(rep).asImmutable(),
    },
  });
};

const createInstance = () => {
  const reader = createReader();
  const fromJSON = (json) => reader.read(json);

  return { fromJSON };
};

export default createInstance();
